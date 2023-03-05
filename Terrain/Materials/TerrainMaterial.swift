//
//  Terrain.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import MetalKit
import Metal

class TerrainMaterial: Material {
    let pipeline: MTLRenderPipelineState
    let samplerState: MTLSamplerState

    let texture: MTLTexture
    let normals: MTLTexture
    let metallic: MTLTexture
    let roughness: MTLTexture
    let ao: MTLTexture?

    init(device: MTLDevice, view: MTKView) async throws {
        let vertexDescriptor = TerrainMaterial.buildVertexDescriptor()
        
        self.pipeline = try TerrainMaterial.buildPipeline(device: device, metalKitView: view, vertexDescriptor: vertexDescriptor)
        
        self.texture = try await TextureManager.shared.addTexture(device: device, path: "/A23DTEX_Albedo_1024.jpg")
        self.normals = try await TextureManager.shared.addTexture(device: device, path: "/A23DTEX_Normal_1024.jpg")
        self.metallic = try await TextureManager.shared.addTexture(device: device, path: "/A23DTEX_Specular_1024.jpg")
        self.roughness = try await TextureManager.shared.addTexture(device: device, path: "/A23DTEX_Roughness_1024.jpg")
        self.ao = try await TextureManager.shared.addTexture(device: device, path: "/A23DTEX_AO_1024.jpg")

//        self.texture = try await TextureManager.shared.addTexture(device: device, path: "/rustediron2_basecolor_1024.png")
//        self.normals = try await TextureManager.shared.addTexture(device: device, path: "/rustediron2_normal_1024.png")
//        self.metallic = try await TextureManager.shared.addTexture(device: device, path: "/rustediron2_metallic_1024.png")
//        self.roughness = try await TextureManager.shared.addTexture(device: device, path: "/rustediron2_roughness_1024.png")
//        self.ao = nil
        
        self.samplerState = TerrainMaterial.buildSamplerState(device: device)
    }
    
    func getPipeline() -> MTLRenderPipelineState {
        self.pipeline
    }
    
    func prepare(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(self.getPipeline())
        
        renderEncoder.setFragmentTexture(self.texture, index: TextureIndex.color.rawValue)
        renderEncoder.setFragmentTexture(self.normals, index: TextureIndex.normals.rawValue)
        renderEncoder.setFragmentTexture(self.metallic, index: TextureIndex.metallic.rawValue)
        renderEncoder.setFragmentTexture(self.roughness, index: TextureIndex.roughness.rawValue)
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
        metalKitView: MTKView,
        vertexDescriptor: MTLVertexDescriptor
    ) throws -> MTLRenderPipelineState {
        /// Build a render state pipeline object
        
        let library = device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "pbrVertexShader")
        let fragmentFunction = library?.makeFunction(name: "pbrFragmentShader")
        
        if vertexFunction == nil || fragmentFunction == nil {
             throw Errors.makeFunctionError
         }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "TerrainPipeline"
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
