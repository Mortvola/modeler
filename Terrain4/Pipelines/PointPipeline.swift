//
//  PointPipeline.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import MetalKit
import Metal

class PointPipeline {
    let pipeline: MTLRenderPipelineState
    
    class MaterialEntry {
        var material: PointMaterial
        
        init(material: PointMaterial) {
            self.material = material
        }
    }
    
    var materials: [UUID?:MaterialEntry] = [:]

    init() throws {
        self.pipeline = try PointPipeline.buildPipeline()
    }

    func prepare(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(self.pipeline)
    }

    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        renderEncoder.setRenderPipelineState(pipeline)
        
//        for (_, entry) in self.materials {
//            if entry.material.objects.count > 0 {
//                entry.material.prepare(renderEncoder: renderEncoder)
//                
//                for point in entry.material.objects {
//                    if !point.disabled && !(point.model?.disabled ?? true) {
//                        try point.draw(renderEncoder: renderEncoder, modelMatrix: point.modelMatrix(), frame: frame)
//                    }
//                }
//            }
//        }
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
        
        let vertexDescriptor = PointPipeline.buildVertexDescriptor()
        
        let library = MetalView.shared.device!.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "pointVertexShader")
        let fragmentFunction = library?.makeFunction(name: "pointFragmentShader")
        
        if vertexFunction == nil || fragmentFunction == nil {
             throw Errors.makeFunctionError
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "PointPipeline"
        pipelineDescriptor.rasterSampleCount = MetalView.shared.view!.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = MetalView.shared.view!.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = MetalView.shared.view!.depthStencilPixelFormat
        
        return try MetalView.shared.device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}

