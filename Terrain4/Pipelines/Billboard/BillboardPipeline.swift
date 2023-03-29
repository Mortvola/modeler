//
//  BillbaordPipeline.swift
//  Terrain4
//
//  Created by Richard Shields on 3/29/23.
//

import Foundation
import MetalKit
import Metal

class BillboardPipeline: Pipeline {
    var pipeline: MTLRenderPipelineState? = nil
    
    func initialize() throws {
        self.pipeline = try buildPipeline(name: "BillboardPipeline", vertexShader: "billboardVertexShader", fragmentShader: "billboardFragmentShader") { descr in
            descr.colorAttachments[0].isBlendingEnabled = true
            descr.colorAttachments[0].rgbBlendOperation = .add
            descr.colorAttachments[0].alphaBlendOperation = .add
            descr.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descr.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            descr.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descr.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }
    }
    
    func prepareObject(object: RenderObject) {
        object.uniformsSize = alignedNodeUniformsSize
        object.uniforms = MetalView.shared.device.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
        object.uniforms!.label = "Node Uniforms"
    }
    
    //    func prepare(renderEncoder: MTLRenderCommandEncoder) {
    //        renderEncoder.setRenderPipelineState(self.pipeline!)
    //    }
    
    func draw(object: RenderObject, renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        let u: UnsafeMutablePointer<BillboardUniforms> = object.getUniformsBuffer(index: frame)
        u[0].color = Vec4(1.0, 1.0, 1.0, 1.0)
        u[0].scale = Vec2(1.0, 1.0)
        
        let (buffer, offset) = object.getInstanceData(frame: frame)
        renderEncoder.setVertexBuffer(buffer, offset: offset, index: BufferIndex.modelMatrix.rawValue)

        renderEncoder.setVertexBuffer(object.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)
        renderEncoder.setFragmentBuffer(object.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)
        
        try object.draw(renderEncoder: renderEncoder)
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        renderEncoder.setRenderPipelineState(pipeline!)
        
        for (_, wrapper) in self.materials {
            if wrapper.material.objects.count > 0 {
                switch wrapper {
                case .billboardMaterial(let material):
                    material.prepare(renderEncoder: renderEncoder, frame: frame)
                    
                    for object in material.objects {
                        if !object.disabled && !(object.model?.disabled ?? true) {
                            try self.draw(object: object, renderEncoder: renderEncoder, frame: frame)
                        }
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    override func buildVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        
        vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = .float2
        vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = MemoryLayout<simd_float3>.stride
        
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = (MemoryLayout<simd_float3>.stride + MemoryLayout<simd_float2>.stride)
        
        return vertexDescriptor
    }
}
