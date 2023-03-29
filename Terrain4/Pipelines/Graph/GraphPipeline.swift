//
//  BillboarPipeline.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import MetalKit
import Metal

class GraphPipeline: Pipeline {
    var pipeline: MTLRenderPipelineState? = nil
    
    func initialize() throws {
        self.pipeline = try buildPipeline(name: "GraphPipeline", vertexShader: "graphVertexShader", fragmentShader: "graphFragmentShader") { descr in
            descr.colorAttachments[0].isBlendingEnabled = true
            descr.colorAttachments[0].rgbBlendOperation = .add
            descr.colorAttachments[0].alphaBlendOperation = .add
            descr.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descr.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            descr.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descr.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            let linkedFunctions = try self.buildStitchedFunction()!
            descr.fragmentLinkedFunctions = linkedFunctions
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
                case .graphMaterial(let material):
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
    
//    private static func buildPipeline() throws -> MTLRenderPipelineState {
//        /// Build a render state pipeline object
//
//        let vertexDescriptor = GraphPipeline.buildVertexDescriptor()
//
//        let library = MetalView.shared.device.makeDefaultLibrary()
//
//        let vertexFunction = library?.makeFunction(name: "graphVertexShader")
//        let fragmentFunction = library?.makeFunction(name: "graphFragmentShader")
//
//        if vertexFunction == nil || fragmentFunction == nil {
//             throw Errors.makeFunctionError
//        }
//
//        let linkedFunctions = try buildStitchedFunction()!
//
//        let pipelineDescriptor = MTLRenderPipelineDescriptor()
//        pipelineDescriptor.label = "GraphPipeline"
//        pipelineDescriptor.rasterSampleCount = MetalView.shared.view!.sampleCount
//        pipelineDescriptor.vertexFunction = vertexFunction
//        pipelineDescriptor.fragmentFunction = fragmentFunction
//        pipelineDescriptor.fragmentLinkedFunctions = linkedFunctions
//        pipelineDescriptor.vertexDescriptor = vertexDescriptor
//
//        pipelineDescriptor.colorAttachments[0].pixelFormat = MetalView.shared.view!.colorPixelFormat
//
//        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
//        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
//        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
//        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
//        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
//
//        pipelineDescriptor.depthAttachmentPixelFormat = MetalView.shared.view!.depthStencilPixelFormat
//
//        return try MetalView.shared.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//    }
    
    private func buildStitchedFunction() throws -> MTLLinkedFunctions? {
        guard let library = MetalView.shared.device.makeDefaultLibrary() else {
            return nil
        }

        let functions = [
            library.makeFunction(name: "readTextureRed")!,
            library.makeFunction(name: "subtract")!,
            library.makeFunction(name: "maxValue")!,
            library.makeFunction(name: "assignAlpha")!
        ]

        let texture = MTLFunctionStitchingInputNode(argumentIndex: 0)
        let sampler = MTLFunctionStitchingInputNode(argumentIndex: 1)
        let texcoord = MTLFunctionStitchingInputNode(argumentIndex: 2)
        let color = MTLFunctionStitchingInputNode(argumentIndex: 3)
        let subValue = MTLFunctionStitchingInputNode(argumentIndex: 4)
        let minValue = MTLFunctionStitchingInputNode(argumentIndex: 5)
        
        let dummy = MTLFunctionStitchingInputNode(argumentIndex: 6)

        let readTextureRedNode = MTLFunctionStitchingFunctionNode(name: "readTextureRed", arguments: [texture, sampler, texcoord], controlDependencies: [])
        let subtractNode = MTLFunctionStitchingFunctionNode(name: "subtract", arguments: [readTextureRedNode, subValue], controlDependencies: [])
        let maxValueNode = MTLFunctionStitchingFunctionNode(name: "maxValue", arguments: [subtractNode, minValue], controlDependencies: [])
        let assignAlphaNode = MTLFunctionStitchingFunctionNode(name: "assignAlpha", arguments: [dummy, maxValueNode, color], controlDependencies: [])
        
        let nodes: [MTLFunctionStitchingFunctionNode] = [
            readTextureRedNode,
            subtractNode,
            maxValueNode
        ]
        
        let graph = MTLFunctionStitchingGraph(functionName: "processTexel", nodes: nodes, outputNode: assignAlphaNode, attributes: [MTLFunctionStitchingAttributeAlwaysInline()])

        let descriptor = MTLStitchedLibraryDescriptor()
        
        descriptor.functions = functions
        descriptor.functionGraphs = [graph]
        
        let stitchedLib = try MetalView.shared.device.makeLibrary(stitchedDescriptor: descriptor)
    
        let funcDesc = MTLFunctionDescriptor()
        funcDesc.name = "processTexel"

        let function = try stitchedLib.makeFunction(descriptor: funcDesc)
        
        let linkedFunctions = MTLLinkedFunctions()
        
        linkedFunctions.privateFunctions = [function]
        
        return linkedFunctions
    }
}
