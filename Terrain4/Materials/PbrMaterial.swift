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
    }

    func setSimpleRoughness(_ value: Float) {
        TextureManager.setTextureValue(texture: self.roughness.simpleTexture!, value: value)
    }
    
    func setSimpleAlbedo(_ color: Vec4) {
        TextureManager.setTextureValue(texture: self.albedo.simpleTexture!, color: color)
    }
    
    init(device: MTLDevice, view: MTKView, descriptor: MaterialDescriptor?) async throws {
        if PbrMaterial.pipeline == nil {
            PbrMaterial.pipeline = try PbrMaterial.buildPipeline(device: device, metalKitView: view)
        }
        
        self.id = descriptor?.id ?? UUID()
        
        self.samplerState = PbrMaterial.buildSamplerState(device: device)

        do {
            // Albedo
            if let material = descriptor, !material.albedo.map.isEmpty {
                self.albedo.map = material.albedo.map
                self.albedo.useSimple = material.albedo.useSimple
                self.albedo.color = material.albedo.color
                
                self.albedo.mapTexture = try? await TextureManager.shared.addTexture(device: device, path: material.albedo.map)
            }

            self.albedo.simpleTexture = try TextureManager.shared.addTexture(device: device, color: Vec4(1.0, 1.0, 1.0, 1.0), pixelFormat: .bgra8Unorm_srgb)
            
            // Normals
            if let material = descriptor, !material.normals.map.isEmpty {
                self.normals.map = material.normals.map
                self.normals.useSimple = material.normals.useSimple
                self.normals.normal = material.normals.normal
                
                self.normals.mapTexture = try? await TextureManager.shared.addTexture(device: device, path: material.normals.map)
            }
            
            let normal = Vec3(0.0, 0.0, 1.0)
                .add(Vec3(1.0, 1.0, 1.0))
                .multiply(Vec3(0.5, 0.5, 0.5))

            self.normals.simpleTexture = try TextureManager.shared.createTexture(device: device, color: Vec4(normal[0], normal[1], normal[2], 1.0), pixelFormat: .bgra8Unorm)
            
            // Metalness
            if let material = descriptor, !material.metallic.map.isEmpty {
                self.metallic.map = material.metallic.map
                self.metallic.useSimple = material.metallic.useSimple
                self.metallic.value = material.metallic.value
                
                self.metallic.mapTexture = try? await TextureManager.shared.addTexture(device: device, path: material.metallic.map)
            }

            self.metallic.simpleTexture = try TextureManager.shared.createTexture(device: device, color: 0.0)

            // Roughness
            if let material = descriptor, !material.roughness.map.isEmpty {
                self.roughness.map = material.roughness.map
                self.roughness.useSimple = material.roughness.useSimple
                self.roughness.value = material.roughness.value
                
                self.roughness.mapTexture = try? await TextureManager.shared.addTexture(device: device, path: material.roughness.map)
            }

            self.roughness.simpleTexture = try TextureManager.shared.createTexture(device: device, color: 1.0)

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
