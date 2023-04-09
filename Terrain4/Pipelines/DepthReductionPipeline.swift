//
//  DepthReductionPipeline.swift
//  Terrain4
//
//  Created by Richard Shields on 4/5/23.
//

import Foundation
import Metal
import MetalKit

class DepthReductionPipeline {
    var pipeline: MTLRenderPipelineState? = nil

    func initialize() throws {
        self.pipeline = try DepthReductionPipeline.buildPipeline()
    }

    func prepare(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(self.pipeline!)
    }
    
    private static func buildPipeline() throws -> MTLRenderPipelineState {
        let library = MetalView.shared.device.makeDefaultLibrary()
        
        let descr = MTLRenderPipelineDescriptor()

        descr.label = "DepthReductionPipeline"
        descr.vertexFunction = library?.makeFunction(name: "depthReductionVertexShader")
        descr.fragmentFunction = library?.makeFunction(name: "depthReductionFragmentShader")
        descr.vertexDescriptor = DepthShadowPipeline.buildVertexDescriptor()
        descr.depthAttachmentPixelFormat = .depth32Float
        descr.stencilAttachmentPixelFormat = MTLPixelFormat.invalid
        descr.colorAttachments[0].pixelFormat = MTLPixelFormat.r32Float // MetalView.shared.view!.colorPixelFormat;

        if descr.vertexFunction == nil {
            throw Errors.makeFunctionError
        }

        return try MetalView.shared.device.makeRenderPipelineState(descriptor: descr)
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
