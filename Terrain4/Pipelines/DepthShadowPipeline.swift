//
//  DepthShadowMaterial.swift
//  Terrain4
//
//  Created by Richard Shields on 3/19/23.
//

import Foundation
import Metal
import MetalKit

class DepthShadowPipeline {
    let pipeline: MTLRenderPipelineState

    init() throws {
        self.pipeline = try DepthShadowPipeline.buildPipeline()
    }

    func prepare(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(self.pipeline)
    }
    
    private static func buildPipeline() throws -> MTLRenderPipelineState {
        let library = MetalView.shared.device.makeDefaultLibrary()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        pipelineDescriptor.label = "DepthShadowPipeline"
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "shadowVertexShader")
        pipelineDescriptor.vertexDescriptor = DepthShadowPipeline.buildVertexDescriptor()
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        if pipelineDescriptor.vertexFunction == nil {
            throw Errors.makeFunctionError
        }

        return try MetalView.shared.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    class func buildVertexDescriptor() -> MTLVertexDescriptor {
        let mtlVertexDescriptor = MTLVertexDescriptor()
        
        // Buffer 1
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = (MemoryLayout<simd_float3>.stride + MemoryLayout<simd_float2>.stride)

        return mtlVertexDescriptor
    }
}
