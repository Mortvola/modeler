//
//  LinePipeline.swift
//  Terrain4
//
//  Created by Richard Shields on 4/3/23.
//

import Foundation
import Metal

class LinePipeline: Pipeline {
    init() {
        super.init(type: .linePipeline)
    }

    override func initialize(transparent: Bool) throws {
//        pipeline = try buildPipeline(
//            name: "LinePipeline",
//            vertexShader: "lineVertexShader",
//            fragmentShader: "simpleFragmentShader",
//            transparent: transparent
//        )
        pipeline = try buildPipeline()
    }

    override func prepareObject(object: RenderObject) {
        object.uniformsSize = alignedNodeUniformsSize
        object.uniforms = MetalView.shared.device.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
        object.uniforms!.label = "Node Uniforms"
    }
    
    override func draw(object: RenderObject, renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        let u: UnsafeMutablePointer<NodeUniforms> = object.getUniformsBuffer(index: frame)
        u[0].color = (object as! WireBox).color

        let (buffer, offset) = object.getInstanceData(frame: frame)
        renderEncoder.setVertexBuffer(buffer, offset: offset, index: BufferIndex.modelMatrix.rawValue)

        renderEncoder.setVertexBuffer(object.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)

        try object.draw(renderEncoder: renderEncoder)
    }
    
    override func buildVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = MemoryLayout<simd_float3>.stride
        
        return vertexDescriptor
    }
    
    func buildPipeline() throws -> MTLRenderPipelineState {
        /// Build a render state pipeline object
        let vertexDescriptor = buildVertexDescriptor()
        
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
