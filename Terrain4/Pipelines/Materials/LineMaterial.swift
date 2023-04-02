//
//  LineMaterial.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import MetalKit
import Metal

class LineMaterial: Material {
    let pipeline: MTLRenderPipelineState
    
    init() throws {
        self.pipeline = try LineMaterial.buildPipeline()
        
        super.init(name: "Line Material")
    }
    
    required init(from decoder: Decoder) throws {
        self.pipeline = try LineMaterial.buildPipeline()

        try super.init(from: decoder)
    }
    
    override func prepare(renderEncoder: MTLRenderCommandEncoder, frame: Int) {
        renderEncoder.setRenderPipelineState(self.getPipeline())
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
        let vertexDescriptor = LineMaterial.buildVertexDescriptor()
        
        let library = MetalView.shared.device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "lineVertexShader")
        let fragmentFunction = library?.makeFunction(name: "simpleFragmentShader")
        
        if vertexFunction == nil || fragmentFunction == nil {
             throw Errors.makeFunctionError
         }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "LinePipeline"
        pipelineDescriptor.rasterSampleCount = MetalView.shared.view!.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = MetalView.shared.view!.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = MetalView.shared.view!.depthStencilPixelFormat
        pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat.invalid
        
        return try MetalView.shared.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}

