//
//  Terrain.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import MetalKit
import Metal

class PbrMaterial: Node, BaseMaterial, Equatable, Hashable {
    static func == (lhs: PbrMaterial, rhs: PbrMaterial) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static var pipeline: MTLRenderPipelineState? = nil
    let samplerState: MTLSamplerState

    var id = UUID()

    var albedo = AlbedoLayer()
    var normals = NormalsLayer()
    var metallic = MetallicLayer()
    var roughness = RoughnessLayer()
    var ao: MTLTexture?

    func setSimpleMetallic(_ value: Float) {
        TextureManager.setTextureValue(texture: self.metallic.simpleTexture!, value: value)
        
        self.metallic.value = value
    }

    func setSimpleRoughness(_ value: Float) {
        TextureManager.setTextureValue(texture: self.roughness.simpleTexture!, value: value)

        self.roughness.value = value
    }
    
    func setSimpleAlbedo(_ color: Vec4) {
        TextureManager.setTextureValue(texture: self.albedo.simpleTexture!, color: color)
        
        self.albedo.color = color
    }
    
    init(device: MTLDevice, view: MTKView, descriptor: MaterialDescriptor?) async throws {
        if PbrMaterial.pipeline == nil {
            PbrMaterial.pipeline = try PbrMaterial.buildPipeline(device: device, metalKitView: view)
        }
        
        self.id = descriptor?.id ?? UUID()
        
        self.samplerState = PbrMaterial.buildSamplerState(device: device)

        do {
            // Albedo
            self.albedo.useSimple = descriptor?.albedo.useSimple ?? false
            self.albedo.color = descriptor?.albedo.color ?? Vec4(1.0, 1.0, 1.0, 1.0)
            self.albedo.map = descriptor?.albedo.map ?? ""
            
            if self.albedo.map.isEmpty {
                self.albedo.mapTexture = try? await TextureManager.shared.addTexture(device: device, path: self.albedo.map)
            }

            self.albedo.simpleTexture = try TextureManager.shared.createTexture(device: device, color: self.albedo.color, pixelFormat: .bgra8Unorm_srgb)
            
            // Normals
            self.normals.useSimple = descriptor?.normals.useSimple ?? false
            self.normals.normal = (Vec4(0.0, 0.0, 1.0, 1.0)
                .add(1.0)
                .multiply(0.5))
            self.normals.map = descriptor?.normals.map ?? ""

            if !self.normals.map.isEmpty {
                self.normals.mapTexture = try? await TextureManager.shared.addTexture(device: device, path: self.normals.map)
            }
            
            self.normals.simpleTexture = try TextureManager.shared.createTexture(device: device, color: self.normals.normal, pixelFormat: .bgra8Unorm)
            
            // Metalness
            self.metallic.useSimple = descriptor?.metallic.useSimple ?? false
            self.metallic.value = descriptor?.metallic.value ?? 1.0
            self.metallic.map = descriptor?.metallic.map ?? ""

            if !self.metallic.map.isEmpty {
                self.metallic.mapTexture = try? await TextureManager.shared.addTexture(device: device, path: self.metallic.map)
            }

            self.metallic.simpleTexture = try TextureManager.shared.createTexture(device: device, color: self.metallic.value)

            // Roughness
            self.roughness.useSimple = descriptor?.roughness.useSimple ?? false
            self.roughness.value = descriptor?.roughness.value ?? 1.0
            self.roughness.map = descriptor?.roughness.map ?? ""

            if !self.roughness.map.isEmpty {
                self.roughness.mapTexture = try? await TextureManager.shared.addTexture(device: device, path: self.roughness.map)
            }

            self.roughness.simpleTexture = try TextureManager.shared.createTexture(device: device, color: self.roughness.value)

            self.ao = nil
        }
        catch {
            print(error);
            
            throw error;
        }
        
        super.init(name: descriptor?.name ?? "")
    }
    
    func getPipeline() -> MTLRenderPipelineState {
        PbrMaterial.pipeline!
    }
    
    func prepare(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(PbrMaterial.pipeline!)
        
        renderEncoder.setFragmentTexture(self.albedo.currentTexture(), index: TextureIndex.color.rawValue)
        renderEncoder.setFragmentTexture(self.normals.currentTexture(), index: TextureIndex.normals.rawValue)
        renderEncoder.setFragmentTexture(self.metallic.currentTexture(), index: TextureIndex.metallic.rawValue)
        renderEncoder.setFragmentTexture(self.roughness.currentTexture(), index: TextureIndex.roughness.rawValue)
        renderEncoder.setFragmentTexture(self.ao, index: TextureIndex.ao.rawValue)

        renderEncoder.setFragmentSamplerState(samplerState, index: SamplerIndex.sampler.rawValue)
    }
    
    class func buildVertexDescriptor() -> MTLVertexDescriptor {
        let mtlVertexDescriptor = MTLVertexDescriptor()
        
        // Buffer 1
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = .float2
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = MemoryLayout<simd_float3>.stride
        
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = (MemoryLayout<simd_float3>.stride + MemoryLayout<simd_float2>.stride)

        // Buffer 2
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].bufferIndex = BufferIndex.normals.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].offset = 0
        
        mtlVertexDescriptor.attributes[VertexAttribute.tangent.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.tangent.rawValue].bufferIndex = BufferIndex.normals.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.tangent.rawValue].offset = MemoryLayout<simd_float3>.stride

        mtlVertexDescriptor.layouts[BufferIndex.normals.rawValue].stride = MemoryLayout<simd_float3>.stride * 2

        return mtlVertexDescriptor
    }
    
    class func buildPipeline(
        device: MTLDevice,
        metalKitView: MTKView
    ) throws -> MTLRenderPipelineState {
        let vertexDescriptor = PbrMaterial.buildVertexDescriptor()
        
        let library = device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "pbrVertexShader")
        let fragmentFunction = library?.makeFunction(name: "pbrFragmentShader")
        
        if vertexFunction == nil || fragmentFunction == nil {
             throw Errors.makeFunctionError
         }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "PbrPipeline"
        pipelineDescriptor.rasterSampleCount = metalKitView.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        //        pipelineDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private static func buildSamplerState(device: MTLDevice) -> MTLSamplerState {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        return device.makeSamplerState(descriptor: samplerDescriptor)!
    }
}
