//
//  Renderer.swift
//  Terrain
//
//  Created by Richard Shields on 2/23/23.
//

// Our platform independent renderer class

import Metal
import MetalKit
import simd

// The 256 byte aligned size of our uniform structure
let alignedUniformsSize = (MemoryLayout<Uniforms>.size + 0xFF) & -0x100

let maxBuffersInFlight = 3

enum RendererError: Error {
    case badVertexDescriptor
}

class Renderer: NSObject, MTKViewDelegate {
    
    public let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var dynamicUniformBuffer: MTLBuffer
    var pipelineState: MTLRenderPipelineState
    var depthState: MTLDepthStencilState
    // var colorMap: MTLTexture
    
    let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)
    
    var uniformBufferOffset = 0
    
    var uniformBufferIndex = 0
    
    var uniforms: UnsafeMutablePointer<Uniforms>
    
    let world = World()
    
    var camera: Camera
    
    init?(metalKitView: MTKView) {
        self.camera = Camera(world: world)
        
        self.device = metalKitView.device!
        guard let queue = self.device.makeCommandQueue() else { return nil }
        self.commandQueue = queue
        
        let uniformBufferSize = alignedUniformsSize * maxBuffersInFlight
        
        guard let buffer = self.device.makeBuffer(length:uniformBufferSize, options:[MTLResourceOptions.storageModeShared]) else { return nil }
        self.dynamicUniformBuffer = buffer
        self.dynamicUniformBuffer.label = "UniformBuffer"
        
        self.uniforms = UnsafeMutableRawPointer(self.dynamicUniformBuffer.contents()).bindMemory(to:Uniforms.self, capacity:1)
        
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float
        metalKitView.colorPixelFormat = .bgra8Unorm_srgb
        metalKitView.sampleCount = 1
        
        let mtlVertexDescriptor = Renderer.buildMetalVertexDescriptor()
        
        do {
            self.pipelineState = try Renderer.buildRenderPipelineWithDevice(device: device,
                                                                            metalKitView: metalKitView,
                                                                            mtlVertexDescriptor: mtlVertexDescriptor)
        } catch {
            print("Unable to compile render pipeline state.  Error info: \(error)")
            return nil
        }
        
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.depthCompareFunction = .less
        depthStateDescriptor.isDepthWriteEnabled = true
        guard let state = device.makeDepthStencilState(descriptor:depthStateDescriptor) else { return nil }
        self.depthState = state
        
        //        do {
        //            mesh = try Renderer.buildMesh(device: device, mtlVertexDescriptor: mtlVertexDescriptor)
        //        } catch {
        //            print("Unable to build MetalKit Mesh. Error info: \(error)")
        //            return nil
        //        }
        
        //        do {
        //            colorMap = try Renderer.loadTexture(device: device, textureName: "ColorMap")
        //        } catch {
        //            print("Unable to load texture. Error info: \(error)")
        //            return nil
        //        }
        
        super.init()
    }

    func load(lat: Double, lng: Double, dimension: Int) async {
        let latLng = LatLng(lat, lng)
        let (x, z) = latLngToTerrainTile(latLng.lat, latLng.lng, dimension);
        
        let swLatLng = terrainTileToLatLng(Double(x), Double(z), dimension);
        let neLatLng = terrainTileToLatLng(Double(x + 1), Double(z + 1), dimension);
        let latLngCenter = LatLng(
            swLatLng.lat + (neLatLng.lat - swLatLng.lat) / 2,
            swLatLng.lng + (neLatLng.lng - swLatLng.lng) / 2
        )
        
        self.camera.scale = cos(degreesToRadians(Float(latLngCenter.lat)));
        
        await self.world.loadTiles(x: x, z: z, dimension: dimension, renderer: self)

        let cameraOffset = self.getCameraOffset(latLng: latLng, latLngCenter: latLngCenter)
        let zOffset = self.world.getElevation(x: cameraOffset.0, y: cameraOffset.1)

        self.camera.cameraOffset = vec3(cameraOffset.0, zOffset, cameraOffset.1)
    }

    func getCameraOffset(latLng: LatLng, latLngCenter: LatLng) -> (Float, Float) {
        let positionMerc = latLngToMercator(lat: latLng.lat, lng: latLng.lng)
        let centerMerc = latLngToMercator(lat: latLngCenter.lat, lng: latLngCenter.lng)

      return (
        Float(positionMerc.0 - centerMerc.0),
        Float(positionMerc.1 - centerMerc.1)
      )
    }

    class func buildMetalVertexDescriptor() -> MTLVertexDescriptor {
        // Create a Metal vertex descriptor specifying how vertices will by laid out for input into our render
        //   pipeline and how we'll layout our Model IO vertices
        
        let mtlVertexDescriptor = MTLVertexDescriptor()
        
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = .float2
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = MemoryLayout<simd_float3>.stride
        
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].offset = MemoryLayout<simd_float3>.stride + MemoryLayout<simd_float2>.stride
        
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = (MemoryLayout<simd_float3>.stride + MemoryLayout<simd_float2>.stride + MemoryLayout<simd_float3>.stride)
        //        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
        //        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = MTLVertexStepFunction.perVertex
        
        //        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = 8 * 4
        //        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
        //        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = MTLVertexStepFunction.perVertex
        
        return mtlVertexDescriptor
    }
    
    class func buildRenderPipelineWithDevice(
        device: MTLDevice,
        metalKitView: MTKView,
        mtlVertexDescriptor: MTLVertexDescriptor
    ) throws -> MTLRenderPipelineState {
        /// Build a render state pipeline object
        
        let library = device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "simpleVertexShader")
        let fragmentFunction = library?.makeFunction(name: "simpleFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.rasterSampleCount = metalKitView.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = mtlVertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        //        pipelineDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    //    class func buildMesh(device: MTLDevice,
    //                         mtlVertexDescriptor: MTLVertexDescriptor) throws -> MTKMesh {
    //        /// Create and condition mesh data to feed into a pipeline using the given vertex descriptor
    //
    //        let metalAllocator = MTKMeshBufferAllocator(device: device)
    //
    //        let mdlMesh = MDLMesh.newBox(withDimensions: SIMD3<Float>(4, 4, 4),
    //                                     segments: SIMD3<UInt32>(2, 2, 2),
    //                                     geometryType: MDLGeometryType.triangles,
    //                                     inwardNormals:false,
    //                                     allocator: metalAllocator)
    //
    //        let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(mtlVertexDescriptor)
    //
    //        guard let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] else {
    //            throw RendererError.badVertexDescriptor
    //        }
    //        attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
    //        attributes[VertexAttribute.texcoord.rawValue].name = MDLVertexAttributeTextureCoordinate
    //
    //        mdlMesh.vertexDescriptor = mdlVertexDescriptor
    //
    //        return try MTKMesh(mesh:mdlMesh, device:device)
    //    }
    
    class func loadTexture(device: MTLDevice,
                           textureName: String) throws -> MTLTexture {
        /// Load texture data with optimal parameters for sampling
        
        let textureLoader = MTKTextureLoader(device: device)
        
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]
        
        return try textureLoader.newTexture(name: textureName,
                                            scaleFactor: 1.0,
                                            bundle: nil,
                                            options: textureLoaderOptions)
        
    }
    
    private func updateDynamicBufferState() {
        /// Update the state of our uniform buffers before rendering
        
        uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
        
        self.uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
        
        self.uniforms = UnsafeMutableRawPointer(self.dynamicUniformBuffer.contents() + self.uniformBufferOffset).bindMemory(to:Uniforms.self, capacity:1)
    }
    
    private func updateGameState(elapsedTime: Float) {
        /// Update any game state before rendering
        
        self.camera.updatePostion(elapsedTime: elapsedTime)
        
        self.uniforms[0].projectionMatrix = self.camera.projectionMatrix
        self.uniforms[0].viewMatrix = self.camera.getViewMatrix()
    }
    
    func draw(in view: MTKView) {
        //        autoreleasepool {
        self.render(in: view)
        //        }
    }
    
    func render(in view: MTKView) {
        /// Per frame updates hare
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            
            let semaphore = inFlightSemaphore
            commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
                semaphore.signal()
            }
            
            self.updateDynamicBufferState()
            
            self.updateGameState(elapsedTime: 1 / Float(view.preferredFramesPerSecond))
            
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            if let renderPassDescriptor = view.currentRenderPassDescriptor {
                //                renderPassDescriptor.colorAttachments[0].loadAction = .clear
                //                renderPassDescriptor.colorAttachments[0].storeAction = .store
                
                if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                    
                    /// Final pass rendering code here
                    renderEncoder.label = "Primary Render Encoder"
                    
                    renderEncoder.pushDebugGroup("Draw Box")
                    
                    renderEncoder.setCullMode(.back)
                    
                    renderEncoder.setFrontFacing(.counterClockwise)
                    
                    renderEncoder.setRenderPipelineState(self.pipelineState)
                    
                    renderEncoder.setDepthStencilState(self.depthState)
                    
                    renderEncoder.setVertexBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
                    //                renderEncoder.setFragmentBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
                    
                    //                for (index, element) in mesh.vertexDescriptor.layouts.enumerated() {
                    //                    guard let layout = element as? MDLVertexBufferLayout else {
                    //                        return
                    //                    }
                    //
                    //                    if layout.stride != 0 {
                    //                        let buffer = mesh.vertexBuffers[index]
                    //                        renderEncoder.setVertexBuffer(buffer.buffer, offset:buffer.offset, index: index)
                    //                    }
                    //                }
                    //
                    //                renderEncoder.setFragmentTexture(colorMap, index: TextureIndex.color.rawValue)
                    //
                    //                for submesh in mesh.submeshes {
                    //                    renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                    //                                                        indexCount: submesh.indexCount,
                    //                                                        indexType: submesh.indexType,
                    //                                                        indexBuffer: submesh.indexBuffer.buffer,
                    //                                                        indexBufferOffset: submesh.indexBuffer.offset)
                    //
                    //                }
                    
                    if world.terrainLoaded {
                        world.draw(renderEncoder: renderEncoder)
                    }
                    
                    renderEncoder.popDebugGroup()
                    
                    renderEncoder.endEncoding()
                    
                    if let drawable = view.currentDrawable {
                        commandBuffer.present(drawable)
                    }
                }
            }
            
            commandBuffer.commit()
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.camera.updateViewDimensions(width: Float(size.width), height: Float(size.height))
    }
}
