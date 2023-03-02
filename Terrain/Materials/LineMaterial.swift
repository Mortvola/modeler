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
    
    init(device: MTLDevice, view: MTKView) throws {
        let vertexDescriptor = LineMaterial.buildVertexDescriptor()
        
        self.pipeline = try LineMaterial.buildPipeline(device: device, metalKitView: view, vertexDescriptor: vertexDescriptor)
    }

    func prepare(renderEncoder: MTLRenderCommandEncoder) {
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
    
    private static func buildPipeline(
        device: MTLDevice,
        metalKitView: MTKView,
        vertexDescriptor: MTLVertexDescriptor
    ) throws -> MTLRenderPipelineState {
        /// Build a render state pipeline object
        
        let library = device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "lineVertexShader")
        let fragmentFunction = library?.makeFunction(name: "simpleFragmentShader")
        
        if vertexFunction == nil || fragmentFunction == nil {
             throw Errors.makeFunctionError
         }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "LinePipeline"
        pipelineDescriptor.rasterSampleCount = metalKitView.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        //        pipelineDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}

