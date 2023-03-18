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
    
    private var commandQueue: MTLCommandQueue?
    private var dynamicUniformBuffer: MTLBuffer?
    private var depthState: MTLDepthStencilState?
    // var colorMap: MTLTexture
    
    private let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)
    
    private var uniformBufferOffset = 0
    
    private var uniformBufferIndex = 0
    
    private var uniforms: UnsafeMutablePointer<Uniforms>?
    
    private let world = World()
    
    public var camera: Camera
    
    private var lightVector = Vec3(0, -1, 1)
    
    private var latitude: Double = 42.0
    
    private var day: Int = 0
    
    private var hour: Float = 10.0
    
    private var previousFrameTime: Double?
    
    init() {
        self.camera = Camera(world: world)
    }

    func initialize(metalKitView: MTKView) throws {
        self.camera = Camera(world: world)
        
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

    public func load(lat: Double, lng: Double, dimension: Int) async throws {
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
    
    private func initializeLightVector(latitude: Double) {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        self.latitude = latitude
        self.day = calendar.ordinality(of: Calendar.Component.day, in: Calendar.Component.year, for: Date.now) ?? 0
        self.hour = 10.0
        
        updateTimeOfDay(elapsedTime: 0)
    }
    
    private func getCameraOffset(latLng: LatLng, latLngCenter: LatLng) -> (Float, Float) {
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
    
    private func updateTimeOfDay(elapsedTime: Double) {
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
                    var t = transform.values

                    if let animator = transform.animator {
                        t = t.add(animator.accum)
                    }

                    switch(transform.transform) {
                    case .translate:
                        return accum.translate(t.x, t.y, t.z)
                        
                    case .rotate:
                        return accum
                            .rotate(radians: degreesToRadians(t.x), axis: Vec3(1, 0, 0))
                            .rotate(radians: degreesToRadians(t.y), axis: Vec3(0, 1, 0))
                            .rotate(radians: degreesToRadians(t.z), axis: Vec3(0, 0, 1))
                        
                    case .scale:
                        return accum.scale(t.x, t.y, t.z)
                    }
                }
                
                model.modelMatrix = transform

                model.objects.forEach { object in
                    
                    object.lights = []
                    
                    ObjectStore.shared.lights.forEach { light in
                        if !light.disabled && !(light.model?.disabled ?? true) {
                            object.lights.append(light)
                        }
                    }
                }
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
//                let rotation = Matrix4x4.rotation(radians: Lights.shared.rotation, axis: Vec3(0, 1, 0))
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
            uniforms[0].lightVector = ObjectStore.shared.directionalLight.direction
            uniforms[0].lightColor = ObjectStore.shared.directionalLight.disabled ? Vec3(0, 0, 0) : ObjectStore.shared.directionalLight.intensity

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

                        ObjectStore.shared.skybox?.draw(renderEncoder: renderEncoder)
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
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.camera.updateViewDimensions(width: Float(size.width), height: Float(size.height))
    }
}
