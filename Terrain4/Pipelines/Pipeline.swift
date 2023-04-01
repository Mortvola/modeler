//
//  Pipeline.swift
//  Terrain4
//
//  Created by Richard Shields on 3/25/23.
//

import Foundation
import Metal

enum PipelineType {
    case pbrPipeline
    case graphPipeline
    case billboardPipeline
}


class Pipeline {
    var materials: [UUID?:MaterialWrapper] = [:]
    
    var type: PipelineType
    
    init(type: PipelineType) {
        self.type = type
    }
    
    func initialize(transparent: Bool) throws {}
    
    func addMaterial(material: MaterialWrapper) {
        let materialKey = material.id
        
        if materials[materialKey] == nil {
            materials[materialKey] = material
        }
    }
    
    func clearDrawables() {
        for material in materials {
            material.value.material.clearDrawables()
        }
    }
    
    func prepareObject(object: RenderObject) {
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        throw Errors.notImplemented
    }

    func buildPipeline(
        name: String,
        vertexShader: String,
        fragmentShader: String,
        transparent: Bool,
        override: ((MTLRenderPipelineDescriptor) throws -> Void)? = nil
    ) throws -> MTLRenderPipelineState {
        let vertexDescriptor = buildVertexDescriptor()
        
        let library = MetalView.shared.device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: vertexShader)
        let fragmentFunction = library?.makeFunction(name: fragmentShader)
        
        if vertexFunction == nil || fragmentFunction == nil {
            throw Errors.makeFunctionError
        }
        
        let descr = MTLRenderPipelineDescriptor()
        descr.label = name
        descr.rasterSampleCount = MetalView.shared.view!.sampleCount
        descr.vertexFunction = vertexFunction
        descr.fragmentFunction = fragmentFunction
        descr.vertexDescriptor = vertexDescriptor
        
        descr.colorAttachments[0].pixelFormat = MetalView.shared.view!.colorPixelFormat
        descr.depthAttachmentPixelFormat = MetalView.shared.view!.depthStencilPixelFormat
        
        if transparent {
            descr.colorAttachments[0].isBlendingEnabled = true
            descr.colorAttachments[0].rgbBlendOperation = .add
            descr.colorAttachments[0].alphaBlendOperation = .add
            descr.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descr.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            descr.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descr.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }
        
        try override?(descr)
        
        return try MetalView.shared.device.makeRenderPipelineState(descriptor: descr)
    }
        
    func buildVertexDescriptor() -> MTLVertexDescriptor {
        let mtlVertexDescriptor = MTLVertexDescriptor()
        
        // Buffer 1
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = .float2
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = MemoryLayout<simd_float3>.stride
        
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = (MemoryLayout<simd_float3>.stride + MemoryLayout<simd_float2>.stride)
        
        // Buffer 2
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].bufferIndex = BufferIndex.normals.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].offset = 0
        
        mtlVertexDescriptor.attributes[VertexAttribute.tangent.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.tangent.rawValue].bufferIndex = BufferIndex.normals.rawValue
        mtlVertexDescriptor.attributes[VertexAttribute.tangent.rawValue].offset = MemoryLayout<simd_float3>.stride
        
        mtlVertexDescriptor.layouts[BufferIndex.normals.rawValue].stride = MemoryLayout<simd_float3>.stride * 2
        
        return mtlVertexDescriptor
    }
}
