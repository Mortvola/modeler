//
//  PbrLineMaterial.swift
//  Terrain
//
//  Created by Richard Shields on 3/4/23.
//

import Foundation
import MetalKit
import Metal

class PbrLineMaterial: Material {
    let pipeline: MTLRenderPipelineState
    let samplerState: MTLSamplerState
    
    //    let texture: MTLTexture
    var normals: MTLTexture? = nil
    var metallic: MTLTexture? = nil
    var roughness: MTLTexture? = nil
    
    init() async throws {
        self.pipeline = try PbrLineMaterial.buildPipeline()
        
        self.normals = try await TextureManager.shared.addTexture(path: "/rustediron2_normal_1024.png")
        self.metallic = try await TextureManager.shared.addTexture(path: "/rustediron2_metallic_1024.png")
        self.roughness = try await TextureManager.shared.addTexture(path: "/rustediron2_roughness_1024.png")
        
        self.samplerState = PbrLineMaterial.buildSamplerState()
        
        super.init(name: "PBR Material")
    }
    
    required init(from decoder: Decoder) throws {
        self.pipeline = try PbrLineMaterial.buildPipeline()

        self.samplerState = PbrLineMaterial.buildSamplerState()
        
        try super.init(from: decoder)

        let task = Task {
            self.normals = try? await TextureManager.shared.addTexture(path: "/rustediron2_normal_1024.png")
            self.metallic = try? await TextureManager.shared.addTexture(path: "/rustediron2_metallic_1024.png")
            self.roughness = try? await TextureManager.shared.addTexture(path: "/rustediron2_roughness_1024.png")
        }

        decoder.addTask(task)
    }
    
    override func prepare(renderEncoder: MTLRenderCommandEncoder, frame: Int) {
        renderEncoder.setRenderPipelineState(self.getPipeline())
        
        renderEncoder.setFragmentTexture(self.normals, index: TextureIndex.normals.rawValue)
        renderEncoder.setFragmentTexture(self.metallic, index: TextureIndex.metallic.rawValue)
        renderEncoder.setFragmentTexture(self.roughness, index: TextureIndex.roughness.rawValue)
        
        renderEncoder.setFragmentSamplerState(samplerState, index: SamplerIndex.sampler.rawValue)
    }
    
    func getPipeline() -> MTLRenderPipelineState {
        self.pipeline
    }
    
    private static func buildVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = MemoryLayout<simd_float3>.stride
        
        return vertexDescriptor
    }
    
    private static func buildPipeline() throws -> MTLRenderPipelineState {
        /// Build a render state pipeline object
        let vertexDescriptor = PbrLineMaterial.buildVertexDescriptor()

        let library = MetalView.shared.device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "pbrLineVertexShader")
        let fragmentFunction = library?.makeFunction(name: "simpleFragmentShader")
        
        if vertexFunction == nil || fragmentFunction == nil {
            throw Errors.makeFunctionError
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "PbrLinePipeline"
        pipelineDescriptor.rasterSampleCount = MetalView.shared.view!.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = MetalView.shared.view!.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = MetalView.shared.view!.depthStencilPixelFormat
        pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat.invalid
        
        return try MetalView.shared.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private static func buildSamplerState() -> MTLSamplerState {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        return MetalView.shared.device.makeSamplerState(descriptor: samplerDescriptor)!
    }
}

