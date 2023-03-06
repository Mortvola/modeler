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
    let test = false
    
    public let device: MTLDevice
    public let view: MTKView
    
    let commandQueue: MTLCommandQueue
    var dynamicUniformBuffer: MTLBuffer
    var depthState: MTLDepthStencilState
    // var colorMap: MTLTexture
    
    let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)
    
    var uniformBufferOffset = 0
    
    var uniformBufferIndex = 0
    
    var uniforms: UnsafeMutablePointer<Uniforms>
    
    let world = World()
    
    var skybox: Skybox?
    
    var camera: Camera
    
    var lightVector = vec3(0, -1, 1)
    
    var latitude: Double = 42.0
    
    var day: Int = 0
    
    var hour: Float = 10.0
    
    var previousFrameTime: Double?
    
    init(metalKitView: MTKView) throws {
        self.camera = Camera(world: world)
        
        self.device = metalKitView.device!
        self.view = metalKitView

        guard let queue = self.device.makeCommandQueue() else {
            throw Errors.makeCommandQueueFailed
        }
        
        self.commandQueue = queue
        
        let uniformBufferSize = alignedUniformsSize * maxBuffersInFlight
        
        guard let buffer = self.device.makeBuffer(length:uniformBufferSize, options:[MTLResourceOptions.storageModeShared]) else {
            throw Errors.makeBufferFailed
        }
        self.dynamicUniformBuffer = buffer
        self.dynamicUniformBuffer.label = "UniformBuffer"
        
        self.uniforms = UnsafeMutableRawPointer(self.dynamicUniformBuffer.contents()).bindMemory(to:Uniforms.self, capacity:1)
        
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float
        metalKitView.colorPixelFormat = .bgra8Unorm_srgb
        metalKitView.sampleCount = 1
        
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.depthCompareFunction = .less
        depthStateDescriptor.isDepthWriteEnabled = true
        
        guard let state = device.makeDepthStencilState(descriptor:depthStateDescriptor) else {
            throw Errors.makeDepthStencilStateFailed
        }
        
        self.depthState = state
        
        super.init()
    }

    func load(lat: Double, lng: Double, dimension: Int) async throws {
        if self.test {
//            try await TestRect(device: self.device, view: self.view)
//            try await TestMesh(device: self.device, view: self.view)

            try await Sphere(device: self.device, view: self.view);
            
            self.world.terrainLoaded = true
        }
        else {
            try await self.skybox = Skybox(device: self.device, view: self.view)

            self.initializeLightVector(latitude: lat)

            let latLng = LatLng(lat, lng)
            let (x, z) = latLngToTerrainTile(latLng.lat, latLng.lng, dimension);

            let swLatLng = terrainTileToLatLng(Double(x), Double(z), dimension);
            let neLatLng = terrainTileToLatLng(Double(x + 1), Double(z + 1), dimension);
            let latLngCenter = LatLng(
                swLatLng.lat + (neLatLng.lat - swLatLng.lat) / 2,
                swLatLng.lng + (neLatLng.lng - swLatLng.lng) / 2
            )

            self.camera.scale = cos(degreesToRadians(Float(latLngCenter.lat)));

            try await self.world.loadTiles(x: x, z: z, dimension: dimension, renderer: self)

            let cameraOffset = self.getCameraOffset(latLng: latLng, latLngCenter: latLngCenter)
            self.camera.cameraOffset = vec3(cameraOffset.0, self.camera.cameraOffset.y, cameraOffset.1)
        }
    }
    
    func initializeLightVector(latitude: Double) {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        self.latitude = latitude
        self.day = calendar.ordinality(of: Calendar.Component.day, in: Calendar.Component.year, for: Date.now) ?? 0
        self.hour = 10.0
        
        updateTimeOfDay(elapsedTime: 0)
    }
    
    func getCameraOffset(latLng: LatLng, latLngCenter: LatLng) -> (Float, Float) {
        let positionMerc = latLngToMercator(lat: latLng.lat, lng: latLng.lng)
        let centerMerc = latLngToMercator(lat: latLngCenter.lat, lng: latLngCenter.lng)

      return (
        Float(positionMerc.0 - centerMerc.0),
        Float(positionMerc.1 - centerMerc.1)
      )
    }
    
    private func updateDynamicBufferState() {
        /// Update the state of our uniform buffers before rendering
        
        uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
        
        self.uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
        
        self.uniforms = UnsafeMutableRawPointer(self.dynamicUniformBuffer.contents() + self.uniformBufferOffset).bindMemory(to:Uniforms.self, capacity:1)
    }
    
    func updateTimeOfDay(elapsedTime: Double) {
        self.hour += Float((1 / 10.0) * elapsedTime)
        self.hour.formTruncatingRemainder(dividingBy: 24.0)

        self.lightVector = getSunLightVector(day: self.day, hour: Double(self.hour), latitude: self.latitude)
    }

    private func updateGameState() {
        /// Update any game state before rendering

        let now = ProcessInfo.processInfo.systemUptime
        
        if let previousFrameTime = self.previousFrameTime {
            let elapsedTime = now - previousFrameTime
            
            self.camera.updatePostion(elapsedTime: elapsedTime)
            
            self.updateTimeOfDay(elapsedTime: elapsedTime)
        }
        
        self.previousFrameTime = now;
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
                        
            self.updateGameState()
            
            self.uniforms[0].projectionMatrix = self.camera.projectionMatrix
            self.uniforms[0].viewMatrix = self.camera.getViewMatrix()
            self.uniforms[0].lightVector = self.lightVector
            self.uniforms[0].cameraPos = self.camera.cameraOffset;
            self.uniforms[0].lightPos = vec3(0.0, 12.0, 0.0);
            self.uniforms[0].lightColor = vec3(500.0, 500.0, 500.0);

            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            if let renderPassDescriptor = view.currentRenderPassDescriptor {
                //                renderPassDescriptor.colorAttachments[0].loadAction = .clear
                //                renderPassDescriptor.colorAttachments[0].storeAction = .store
                
                if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                    
                    /// Final pass rendering code here
                    renderEncoder.label = "Primary Render Encoder"
                    
                    renderEncoder.pushDebugGroup("Draw Box")
                    
                    renderEncoder.setFrontFacing(.counterClockwise)
                    renderEncoder.setCullMode(.back)
                    renderEncoder.setDepthStencilState(self.depthState)
                    
                    renderEncoder.setVertexBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)

                    renderEncoder.setFragmentBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)

                    if self.world.terrainLoaded {
                        MaterialManager.shared.render(renderEncoder: renderEncoder)

                        self.skybox?.draw(renderEncoder: renderEncoder)
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
