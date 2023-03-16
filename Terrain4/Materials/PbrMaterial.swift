//
//  Terrain.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import MetalKit
import Metal

class PbrMaterial: BaseMaterial {
    static var pipeline: MTLRenderPipelineState? = nil
    let samplerState: MTLSamplerState

    struct TextureStyle {
        var map: MTLTexture? = nil
        var simple: MTLTexture? = nil
        var useSimple = false
    }
        
    var albedo = TextureStyle()
    var normals = TextureStyle()
    var metallic = TextureStyle()
    var roughness = TextureStyle()
    var ao: MTLTexture?

    func useTextureStyle(style: TextureStyle) -> MTLTexture {
        if let map = style.map, !style.useSimple {
            return map
        }
        
        return style.simple!
    }
    
    var currentAlbedo: MTLTexture {
        useTextureStyle(style: albedo)
    }

    var currentNormals: MTLTexture {
        useTextureStyle(style: normals)
    }

    var currentMetallic: MTLTexture {
        useTextureStyle(style: metallic)
    }

    var currentRoughness: MTLTexture {
        useTextureStyle(style: roughness)
    }

    func setSimpleMetallic(_ value: Float) {
        TextureManager.setTextureValue(texture: self.metallic.simple!, value: value)
    }

    func setSimpleRoughness(_ value: Float) {
        TextureManager.setTextureValue(texture: self.roughness.simple!, value: value)
    }
    
    func setSimpleAlbedo(_ color: Vec4) {
        TextureManager.setTextureValue(texture: self.albedo.simple!, color: color)
    }
    
    init(device: MTLDevice, view: MTKView, material: Material?) async throws {
        if PbrMaterial.pipeline == nil {
            PbrMaterial.pipeline = try PbrMaterial.buildPipeline(device: device, metalKitView: view)
        }
        
        self.samplerState = PbrMaterial.buildSamplerState(device: device)

        do {
            // Albedo
            if let material = material, !material.albedo.isEmpty {
                self.albedo.map = try? await TextureManager.shared.addTexture(device: device, path: material.albedo)
            }

            self.albedo.simple = try TextureManager.shared.addTexture(device: device, color: Vec4(1.0, 1.0, 1.0, 1.0), pixelFormat: .bgra8Unorm_srgb)
            
            // Normals
            if let material = material, !material.normals.isEmpty {
                self.normals.map = try? await TextureManager.shared.addTexture(device: device, path: material.normals)
            }
            
            let normal = Vec3(0.0, 0.0, 1.0)
                .add(Vec3(1.0, 1.0, 1.0))
                .multiply(Vec3(0.5, 0.5, 0.5))

            self.normals.simple = try TextureManager.shared.createTexture(device: device, color: Vec4(normal[0], normal[1], normal[2], 1.0), pixelFormat: .bgra8Unorm)
            
            // Metalness
            if let material = material, !material.metalness.isEmpty {
                self.metallic.map = try? await TextureManager.shared.addTexture(device: device, path: material.metalness)
            }

            self.metallic.simple = try TextureManager.shared.createTexture(device: device, color: 0.0)

            // Roughness
            if let material = material, !material.roughness.isEmpty {
                self.roughness.map = try? await TextureManager.shared.addTexture(device: device, path: material.roughness)
            }

            self.roughness.simple = try TextureManager.shared.createTexture(device: device, color: 1.0)

            self.ao = nil
        }
        catch {
            print(error);
            
            throw error;
        }
    }
    
    func getPipeline() -> MTLRenderPipelineState {
        PbrMaterial.pipeline!
    }
    
    func prepare(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(PbrMaterial.pipeline!)
        
        renderEncoder.setFragmentTexture(self.currentAlbedo, index: TextureIndex.color.rawValue)
        renderEncoder.setFragmentTexture(self.currentNormals, index: TextureIndex.normals.rawValue)
        renderEncoder.setFragmentTexture(self.currentMetallic, index: TextureIndex.metallic.rawValue)
        renderEncoder.setFragmentTexture(self.currentRoughness, index: TextureIndex.roughness.rawValue)
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
