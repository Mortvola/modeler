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
let alignedUniformsSize = (MemoryLayout<FrameUniforms>.size + 0xFF) & -0x100

let maxBuffersInFlight = 3

enum RendererError: Error {
    case badVertexDescriptor
}

enum ViewMode {
    case model
    case scene
}

class Renderer {
    static var shared: Renderer = Renderer()
    
    private var commandQueue: MTLCommandQueue?
    public var dynamicUniformBuffer: MTLBuffer?
    public var depthState: MTLDepthStencilState?
    public var shadowDepthState: MTLDepthStencilState?
    public var transparentDepthState: MTLDepthStencilState?
    
    private let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)
    
    public var uniformBufferOffset = 0
    
    public var uniformBufferIndex = 0
    
    private var uniforms: UnsafeMutablePointer<FrameUniforms>?
    
    public let world = World()
    
    public var camera: Camera
    
    private var lightVector = Vec3(0, -1, 1)
    
    private var latitude: Double = 42.0
    
    private var day: Int = 0
    
    private var hour: Float = 10.0
    
    private var previousFrameTime: Double?
        
    public var objectStore: ObjectStore?
    
    private var lineMaterial: LineMaterial?
    
//    private var fustrums: [WireBox] = []
//
//    private var lightFustrums: [WireBox] = []
    
    public var freezeFustrum = false

    public let pipelineManager: PipelineManager
    
    public let materialManager: MaterialManager
    
    public var textureStore: TextureStore? = nil
    
    private var initialized = false
    
    init() {
        self.camera = Camera(world: world)
        
        self.materialManager = MaterialManager()
        
        self.pipelineManager = PipelineManager()
    }
    
    func initialize(file: SceneDocument) throws {
        self.objectStore = file.objectStore
        
        self.camera = Camera(world: world)
        
        guard let queue = MetalView.shared.device.makeCommandQueue() else {
            throw Errors.makeCommandQueueFailed
        }
        
        self.commandQueue = queue

        try makeUniformsBuffer()
        
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.depthCompareFunction = .less
        depthStateDescriptor.isDepthWriteEnabled = true
        
        guard let state = MetalView.shared.device.makeDepthStencilState(descriptor:depthStateDescriptor) else {
            throw Errors.makeDepthStencilStateFailed
        }
        
        self.depthState = state

        guard let state = MetalView.shared.device.makeDepthStencilState(descriptor:depthStateDescriptor) else {
            throw Errors.makeDepthStencilStateFailed
        }
        
        self.shadowDepthState = state
        
        depthStateDescriptor.isDepthWriteEnabled = false

        guard let state = MetalView.shared.device.makeDepthStencilState(descriptor:depthStateDescriptor) else {
            throw Errors.makeDepthStencilStateFailed
        }
        
        self.transparentDepthState = state
        
        self.lineMaterial = try LineMaterial()
        
        try self.pipelineManager.initialize()
        
        self.textureStore = try TextureStore()
        
        self.initialized = true
    }
    
    func makeUniformsBuffer() throws {
        let uniformBufferSize = alignedUniformsSize * maxBuffersInFlight
        
        guard let buffer = MetalView.shared.device.makeBuffer(length:uniformBufferSize, options:[MTLResourceOptions.storageModeShared]) else {
            throw Errors.makeBufferFailed
        }
        
        buffer.label = "Frame Uniforms"
        self.dynamicUniformBuffer = buffer
        
        self.uniforms = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to: FrameUniforms.self, capacity: 1)
    }
    
//    public func load(lat: Double, lng: Double, dimension: Int) async throws {
//        if self.test {
////            self.world.terrainLoaded = true
//        }
//        else {
//            self.initializeLightVector(latitude: lat)
//
//            let latLng = LatLng(lat, lng)
//            let (x, z) = latLngToTerrainTile(latLng.lat, latLng.lng, dimension)
//
//            let swLatLng = terrainTileToLatLng(Double(x), Double(z), dimension)
//            let neLatLng = terrainTileToLatLng(Double(x + 1), Double(z + 1), dimension)
//            let latLngCenter = LatLng(
//                swLatLng.lat + (neLatLng.lat - swLatLng.lat) / 2,
//                swLatLng.lng + (neLatLng.lng - swLatLng.lng) / 2
//            )
//
//            self.camera.scale = cos(degreesToRadians(Float(latLngCenter.lat)))
//
//            try await self.world.loadTiles(x: x, z: z, dimension: dimension, renderer: self)
//
//            let cameraOffset = self.getCameraOffset(latLng: latLng, latLngCenter: latLngCenter)
//            self.camera.cameraOffset = Vec3(cameraOffset.0, self.camera.cameraOffset.y, cameraOffset.1)
//        }
//    }
    
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
        
        self.uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents() + self.uniformBufferOffset).bindMemory(to: FrameUniforms.self, capacity: 1)
    }
    
    private func updateTimeOfDay(elapsedTime: Double) {
        self.hour += Float((1 / 10.0) * elapsedTime)
        self.hour.formTruncatingRemainder(dividingBy: 24.0)
        
        self.lightVector = getSunLightVector(day: self.day, hour: Double(self.hour), latitude: self.latitude)
    }
    
    func getElapsedTime() -> Double? {
        let now = ProcessInfo.processInfo.systemUptime

        defer {
            previousFrameTime = now
        }
        
        if MovieManager.shared.recording {
            return 1 / 30.0
        }
        else {
            if let previousFrameTime = previousFrameTime {
                let elapsedTime = now - previousFrameTime
                
                return elapsedTime
            }
        }
        
        return nil
    }
    
    func computeAnimatorTransform(sceneModel: SceneModel) -> Matrix4x4 {
        let transform = sceneModel.animators.reduce(Matrix4x4.identity()) { accum, animator in
            let t = animator.value + animator.accum
            
            switch(animator.type) {
//            case .translate:
//                return accum.translate(t.x, t.y, t.z)
                
            case .rotateX:
                return accum
                    .rotate(radians: degreesToRadians(t), axis: Vec3(1, 0, 0))
                
            case .rotateY:
                return accum
                    .rotate(radians: degreesToRadians(t), axis: Vec3(0, 1, 0))
                
            case .rotateZ:
                return accum
                    .rotate(radians: degreesToRadians(t), axis: Vec3(0, 0, 1))
                
//            case .scale:
//                return accum.scale(t.x, t.y, t.z)
            }
        }

        return transform
    }
    
    private func updateModel(model: Model, matrix: Matrix4x4) {
        model.modelMatrix = matrix
        
        for object in model.objects {
            switch object.content {
            case .model:
                break
            case .mesh(let o):
                o.lights = []
                
                objectStore!.currentScene!.lights.forEach { light in
                    if !light.disabled && !(light.model?.disabled ?? true) {
                        o.lights.append(light)
                    }
                }
                
                let transformation = model.modelMatrix * o.transformation()
                
                o.instanceData.append(InstanceData(transformation: transformation))
            case .point:
                break
            case .light(let light):
                let newLight = Light(model: nil)
                newLight.position = model.modelMatrix.multiply(light.position.vec4()).vec3()
                newLight.intensity = light.intensity
                objectStore!.currentScene!.lights.append(newLight)
                break
            case .directionalLight:
                break
            }
        }
        
//        // Add any lights attached to the model to the global list of lights.
//        for light in model.lights {
//            let newLight = Light(model: nil)
//            newLight.position = model.modelMatrix.multiply(light.position.vec4()).vec3()
//            newLight.intensity = light.intensity
//            objectStore!.lights.append(newLight)
//        }
    }

    func clearInstanceData() {
        for node in objectStore!.models {
            switch node.content {
            case .model(let model):
                model.objects.forEach { object in
                    switch object.content {
                    case .model:
                        break
                    case .mesh(let o):
                        o.instanceData = []
                    case .point:
                        break
                    case .light:
                        break
                    case .directionalLight:
                        break
                    }
                }
            default:
                break
            }
        }
    }
    
    private func updateState() {
        /// Update any game state before rendering
        
        if let elapsedTime = getElapsedTime() {
            self.camera.updatePostion(elapsedTime: elapsedTime)
            
            self.updateTimeOfDay(elapsedTime: elapsedTime)
            
            // Update all of the animators
            for animator in objectStore!.animators {
                animator.accum = animator.accum + (animator.value * Float(elapsedTime))
            }

            clearInstanceData()
            objectStore!.currentScene!.lights = []
            
            // Update the model matrix for each model
            switch currentViewMode {
            case .scene:
                if let scene = objectStore?.scene {
                    for sceneModel in scene.models {
                        let transform = computeAnimatorTransform(sceneModel: sceneModel)
                        updateModel(model: sceneModel.model!, matrix: transform * sceneModel.transformation())
                    }
                }
            case .model:
                for node in objectStore!.models {
                    switch node.content {
                    case .model(let m):
                        updateModel(model: m, matrix: Matrix4x4.identity())
                    default:
                        break
                    }
                }
            }
        }
    }
    
    var currentViewMode = ViewMode.model
    var selectedModel: Model? = nil
    
    func setSelectedModel(model: Model?) {
        if (model !== selectedModel) {
            selectedModel = model
            
            objectStore?.modelingScene.models = []
            if let model = model {
                objectStore?.modelingScene.models =
                [SceneModel(model: model)]
            }
            
            switch currentViewMode {
            case .scene:
                break
            case .model:
                pipelineManager.clearDrawables()

                if let model = selectedModel {
                    for object in model.objects {
                        switch object.content {
                        case .mesh (let mesh):
                            mesh.material?.material.addObject(object: mesh)
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    func setViewMode(viewMode: ViewMode) {
        switch viewMode {
        case .scene:
            switch currentViewMode {
            case .scene:
                break
            case .model:
                pipelineManager.clearDrawables()

                if let scene = objectStore?.scene.models {
                    for model in scene {
                        for object in model.model!.objects {
                            switch object.content {
                            case .mesh(let m):
                                m.material?.material.addObject(object: m)
                            default:
                                break
                            }
                        }
                    }
                }
                
                objectStore?.currentScene = objectStore?.scene
            }
            break
            
        case .model:
            switch currentViewMode {
            case .scene:
                pipelineManager.clearDrawables()

                if let model = selectedModel {
                    for object in model.objects {
                        switch object.content {
                        case .mesh (let mesh):
                            mesh.material?.material.addObject(object: mesh)
                        default:
                            break
                        }
                    }
                }
                
                objectStore?.currentScene = objectStore?.modelingScene

            case .model:
                break
            }
        }
        
        currentViewMode = viewMode
    }
    
    func render(in view: MTKView) throws {
        guard let uniforms = self.uniforms else {
            return
        }
        
        guard let commandQueue = self.commandQueue else {
            return
        }
        
        if self.objectStore?.loaded ?? false && self.initialized && objectStore?.currentScene != nil {
            
            _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
            if let commandBuffer = commandQueue.makeCommandBuffer() {
                commandBuffer.label = "\(self.uniformBufferIndex)"
            
                self.updateDynamicBufferState()
                
                self.updateState()
                
                uniforms[0].projectionMatrix = self.camera.projectionMatrix
                uniforms[0].viewMatrix = self.camera.getViewMatrix()
                uniforms[0].cameraPos = self.camera.cameraOffset
                uniforms[0].directionalLight.lightVector = objectStore!.currentScene?.directionalLight?.direction ?? Vec3(0, 0, 0)
                uniforms[0].directionalLight.lightColor = objectStore!.directionalLight.disabled ? Vec3(0, 0, 0) : objectStore!.directionalLight.intensity
                
                if let directionalLight = objectStore!.currentScene?.directionalLight {
                    let fustrumSegments: [Float] = [1, 70, 170, 400, 1600]
                    withUnsafeMutableBytes(of: &uniforms[0].directionalLight.viewProjectionMatrix) { rawPtr in
                        let matrix = rawPtr.baseAddress!.assumingMemoryBound(to: Matrix4x4.self)
                        
                        for i in 0..<shadowMapCascades {
                            let cameraFustrum = camera.getFustrumCorners(nearZ: fustrumSegments[i], farZ: fustrumSegments[i + 1])
                            matrix[i] = directionalLight.calculateProjectionViewMatrix(cameraFustrum: cameraFustrum)
                        }
                    }
                }
                
                //            if self.fustrums.count == 0 {
                //                self.fustrums.append(WireBox(device: device!, points: objectStore!.directionalLight.cameraFustrum, color: Vec4(1, 0, 0, 1)))
                //                self.fustrums.append(WireBox(device: device!, points: objectStore!.directionalLight.cameraFustrum, color: Vec4(1, 0, 0, 1)))
                //                self.fustrums.append(WireBox(device: device!, points: objectStore!.directionalLight.cameraFustrum, color: Vec4(1, 0, 0, 1)))
                //            }
                //
                //            if self.lightFustrums.count == 0 {
                //                self.lightFustrums.append(WireBox(device: device!, points: objectStore!.directionalLight.cameraFustrum, color: Vec4(0, 1, 0, 1)))
                //                self.lightFustrums.append(WireBox(device: device!, points: objectStore!.directionalLight.cameraFustrum, color: Vec4(0, 1, 0, 1)))
                //                self.lightFustrums.append(WireBox(device: device!, points: objectStore!.directionalLight.cameraFustrum, color: Vec4(1, 1, 0, 1)))
                //            }
                
                try renderShadowPass(commandBuffer: commandBuffer)
                
                commandBuffer.commit()
                
                if let commandBuffer = commandQueue.makeCommandBuffer() {
                    commandBuffer.label = "\(self.uniformBufferIndex)"
                    
                    /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
                    ///   holding onto the drawable and blocking the display pipeline any longer than necessary
                    if let renderPassDescriptor = view.currentRenderPassDescriptor {
                        
                        if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                            
                            try renderMainPass(renderEncoder: renderEncoder, commandBuffer: commandBuffer)
                            
                            try renderTransparentPass(renderEncoder: renderEncoder, commandBuffer: commandBuffer)
                            
                            renderEncoder.endEncoding()
                        }

                        if let drawable = view.currentDrawable {
                            commandBuffer.present(drawable)
                        }
                    }
                    
                    let semaphore = inFlightSemaphore
                    commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
                        semaphore.signal()
                    }
                    
                    commandBuffer.commit()
                }
                else {
                    inFlightSemaphore.signal()
                }
                
                if MovieManager.shared.recording {
                    if let texture = view.currentDrawable?.texture, !texture.isFramebufferOnly {
                        commandBuffer.waitUntilCompleted()
                        
                        if let image = try? texture.toImage() {
                            //                        print("captured image \(image.width)x\(image.height)")
                            MovieManager.shared.addFrame(image: image) {
                                view.framebufferOnly = true
                            }
                        }
                    }
                }
            }
        }
        else {
            inFlightSemaphore.signal()
        }
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.camera.updateViewDimensions(width: Float(size.width), height: Float(size.height))
    }

    func startVideoCapture() {
        MetalView.shared.view!.framebufferOnly = false

        Task {
            let width = 1280
            let height = 720
            try? MovieManager.shared.startMovieCreation(width: width, height: height, duration: 10)
        }
    }
}

extension MTLTexture {
  
    func bytes() throws -> UnsafeMutableRawPointer {
        let width = self.width
        let height = self.height
        let rowBytes = self.width * 4
        let p = UnsafeMutableRawPointer.allocate(byteCount: width * height * 4, alignment: 0)

        self.getBytes(p, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)

        return p
    }
  
    func toImage() throws -> CGImage? {
        let p = try bytes()
    
        let pColorSpace = CGColorSpaceCreateDeviceRGB()
    
        let rawBitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
    
        let selftureSize = self.width * self.height * 4
        let rowBytes = self.width * 4
        let provider = CGDataProvider(dataInfo: nil, data: p, size: selftureSize) { _, _, _ in
              
        }
      
        guard let provider = provider else {
            throw Errors.mallocError
        }
        
        let cgImage = CGImage(width: self.width, height: self.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: rowBytes, space: pColorSpace, bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)!
    
        return cgImage
    }
}
