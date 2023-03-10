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

class Renderer {
    static var shared = Renderer()
    let test = true
    
    public var device: MTLDevice?
    public var view: MTKView?
    
    var commandQueue: MTLCommandQueue?
    var dynamicUniformBuffer: MTLBuffer?
    var depthState: MTLDepthStencilState?
    // var colorMap: MTLTexture
    
    let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)
    
    var uniformBufferOffset = 0
    
    var uniformBufferIndex = 0
    
    var uniforms: UnsafeMutablePointer<Uniforms>?
    
    let world = World()
    
    var skybox: Skybox?
    
    var camera: Camera
    
    var lightVector = Vec3(0, -1, 1)
    
    var latitude: Double = 42.0
    
    var day: Int = 0
    
    var hour: Float = 10.0
    
    var previousFrameTime: Double?
    
    var lights: Lights?
    
    init() {
        self.camera = Camera(world: world)
    }

    func initialize(metalKitView: MTKView, lights: Lights) throws {
        self.camera = Camera(world: world)
        self.lights = lights
        
        self.device = metalKitView.device!
        self.view = metalKitView

        guard let queue = metalKitView.device!.makeCommandQueue() else {
            throw Errors.makeCommandQueueFailed
        }
        
        self.commandQueue = queue
        
        let uniformBufferSize = alignedUniformsSize * maxBuffersInFlight
        
        guard let buffer = metalKitView.device!.makeBuffer(length:uniformBufferSize, options:[MTLResourceOptions.storageModeShared]) else {
            throw Errors.makeBufferFailed
        }

        buffer.label = "UniformBuffer"
        self.dynamicUniformBuffer = buffer

        self.uniforms = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to:Uniforms.self, capacity:1)
        
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float
        metalKitView.colorPixelFormat = .bgra8Unorm_srgb
        metalKitView.sampleCount = 1
        
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.depthCompareFunction = .less
        depthStateDescriptor.isDepthWriteEnabled = true
        
        guard let state = metalKitView.device!.makeDepthStencilState(descriptor:depthStateDescriptor) else {
            throw Errors.makeDepthStencilStateFailed
        }
        
        self.depthState = state
    }

    func load(lat: Double, lng: Double, dimension: Int) async throws {
        guard let device = self.device else {
            throw Errors.deviceNotSet
        }
        
        guard let view = self.view else {
            throw Errors.viewNotSet
        }

        try await self.skybox = Skybox(device: device, view: view)

        if self.test {
//            try await TestMesh(device: self.device, view: self.view)
            
            self.world.terrainLoaded = true
        }
        else {
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
            self.camera.cameraOffset = Vec3(cameraOffset.0, self.camera.cameraOffset.y, cameraOffset.1)
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
        
        guard let dynamicUniformBuffer = self.dynamicUniformBuffer else {
            return
        }
        
        uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
        
        self.uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
        
        self.uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents() + self.uniformBufferOffset).bindMemory(to:Uniforms.self, capacity:1)
    }
    
    func updateTimeOfDay(elapsedTime: Double) {
        self.hour += Float((1 / 10.0) * elapsedTime)
        self.hour.formTruncatingRemainder(dividingBy: 24.0)

        self.lightVector = getSunLightVector(day: self.day, hour: Double(self.hour), latitude: self.latitude)
    }

    private func updateState() {
        /// Update any game state before rendering

        let now = ProcessInfo.processInfo.systemUptime
        
        if let previousFrameTime = self.previousFrameTime {
            let elapsedTime = now - previousFrameTime
            
            self.camera.updatePostion(elapsedTime: elapsedTime)
            
            self.updateTimeOfDay(elapsedTime: elapsedTime)
            
            // Update the animators
            AnimatorStore.shared.animators.forEach { animator in
                animator.accum = animator.accum.add(animator.delta.multiply(Float(elapsedTime)))
            }
            
            // Update the model matrix for each model
            ObjectStore.shared.models.forEach { model in
                let transform = model.transforms.reversed().reduce(Matrix4x4.identity()) { accum, transform in
                    switch(transform.transform) {
                    case .translate:
                        return accum.multiply(Matrix4x4.translation(transform.values.x, transform.values.y, transform.values.z))
                    case .rotate:
                        var t = transform.values

                        if let animator = transform.animator {
                            t = t.add(animator.accum)
                        }

                        return accum.multiply(
                                Matrix4x4.rotation(radians: degreesToRadians(t.x), axis: Vec3(1, 0, 0)))
                            .multiply(
                                Matrix4x4.rotation(radians: degreesToRadians(t.y), axis: Vec3(0, 1, 0)))
                            .multiply(Matrix4x4.rotation(radians: degreesToRadians(t.z), axis: Vec3(0, 0, 1)))
                    case .scale:
                        return accum.multiply(Matrix4x4.identity())
                    }
                }
                
                model.modelMatrix = transform
            }
            
//            if Lights.shared.rotateObject {
//                if let testModel = self.testModel {
//                    let r = Float((2 * .pi) / 4 * elapsedTime)
//                    testModel.rotation += r
//
//                    if testModel.rotation > 2 * .pi {
//                        testModel.rotation = (2 * .pi).remainder(dividingBy: 2 * .pi)
//                    }
//
//                    testModel.setRotationY(radians: testModel.rotation, axis: Vec3(0, 1, 0))
//                }
//            }
            
//            if Lights.shared.rotateLight {
//                let r = Float((2 * .pi) / 4 * elapsedTime)
//                Lights.shared.rotation += r
//
//                if Lights.shared.rotation > 2 * .pi {
//                    Lights.shared.rotation = (2 * .pi).remainder(dividingBy: 2 * .pi)
//                }
//
//                let translation = matrix4x4_translation(0, 0, -11)
//                let rotation = matrix4x4_rotation(radians: Lights.shared.rotation, axis: Vec3(0, 1, 0))
//
//                var position = translation.multiply(Vec4(0, 0, 0, 1))
//                position = rotation.multiply(position)
//
//                Lights.shared.position = Vec3(position.x, position.y, position.z)
//            }
        }
        
        self.previousFrameTime = now;
    }
    
    func render(in view: MTKView) throws {
        /// Per frame updates hare
        ///
        
        guard let uniforms = self.uniforms else {
            return
        }
        
        guard let commandQueue = self.commandQueue else {
            return
        }
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            
            let semaphore = inFlightSemaphore
            commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
                semaphore.signal()
            }
            
            self.updateDynamicBufferState()
                        
            self.updateState()
            
            uniforms[0].projectionMatrix = self.camera.projectionMatrix
            uniforms[0].viewMatrix = self.camera.getViewMatrix()
            uniforms[0].cameraPos = self.camera.cameraOffset
            uniforms[0].lightVector = self.lightVector
            uniforms[0].pointLight = Lights.shared.pointLight
            uniforms[0].lightPos = self.lights!.position
            uniforms[0].lightColor = Vec3(self.lights!.red, self.lights!.green, self.lights!.blue)

            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            if let renderPassDescriptor = view.currentRenderPassDescriptor {
                //                renderPassDescriptor.colorAttachments[0].loadAction = .clear
                //                renderPassDescriptor.colorAttachments[0].storeAction = .store
                
                if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                    
                    /// Final pass rendering code here
                    renderEncoder.label = "Primary Render Encoder"
                    
                    renderEncoder.pushDebugGroup("Draw Box")
                    
                    renderEncoder.setFrontFacing(.clockwise)
                    renderEncoder.setCullMode(.back)
                    renderEncoder.setDepthStencilState(self.depthState)
                    
                    renderEncoder.setVertexBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)

                    renderEncoder.setFragmentBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)

                    if self.world.terrainLoaded {
                        try MaterialManager.shared.render(renderEncoder: renderEncoder)

//                        if Lights.shared.enableSkybox {
//                            self.skybox?.draw(renderEncoder: renderEncoder)
//                        }
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