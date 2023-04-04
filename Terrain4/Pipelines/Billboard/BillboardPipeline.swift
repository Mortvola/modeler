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
    init() {
        super.init(type: .billboardPipeline)
    }

    override func initialize(transparent: Bool) throws {
        self.pipeline = try buildPipeline(
            name: "BillboardPipeline",
            vertexShader: "billboardVertexShader",
            fragmentShader: transparent ? "billboardFragmentTransparencyShader" : "billboardFragmentShader",
            transparent: transparent
        )
    }
    
    override func prepareObject(object: RenderObject) {
        object.uniformsSize = alignedNodeUniformsSize
        object.uniforms = MetalView.shared.device.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
        object.uniforms!.label = "Node Uniforms"
    }
    
    override func draw(object: RenderObject, renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        let u: UnsafeMutablePointer<BillboardUniforms> = object.getUniformsBuffer(index: frame)
        u[0].color = Vec4(1.0, 1.0, 1.0, 1.0)
        u[0].scale = Vec2(1.0, 1.0)
        
        let (buffer, offset) = object.getInstanceData(frame: frame)
        renderEncoder.setVertexBuffer(buffer, offset: offset, index: BufferIndex.modelMatrix.rawValue)

        renderEncoder.setVertexBuffer(object.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)
        renderEncoder.setFragmentBuffer(object.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)
        
        try object.draw(renderEncoder: renderEncoder)
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
