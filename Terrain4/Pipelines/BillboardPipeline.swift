//
//  BillboarPipeline.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import MetalKit
import Metal

class BillboardPipeline {
    let pipeline: MTLRenderPipelineState
    
    class MaterialEntry {
        var material: SimpleMaterial
        
        init(material: SimpleMaterial) {
            self.material = material
        }
    }
    
    var materials: [UUID?:MaterialEntry] = [:]

    init(device: MTLDevice, view: MTKView) throws {
        self.pipeline = try BillboardPipeline.buildPipeline(device: device, metalKitView: view)
    }

    func prepare(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(self.pipeline)
    }

//    func addMaterial(device: MTLDevice, view: MTKView, descriptor: MaterialDescriptor?) async throws -> SimpleMaterial {
//
//        let materialKey = descriptor?.id
//
//        if let entry = self.materials[materialKey] {
//            return entry.material
//        }
//
//        let material = try await SimpleMaterial(device: device, view: view, descriptor: descriptor)
//
//        let entry = MaterialEntry(material: material)
//        self.materials[materialKey] = entry
//
//        return material
//    }

    func addMaterial(material: SimpleMaterial) {
        let materialKey = material.id
        
        if materials[materialKey] == nil {
            materials[materialKey] = MaterialEntry(material: material)
        }
    }

    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        renderEncoder.setRenderPipelineState(pipeline)
        
        for (_, entry) in self.materials {
            if entry.material.objects.count > 0 {
                entry.material.prepare(renderEncoder: renderEncoder)
                
                for object in entry.material.objects {
                    if !object.disabled && !(object.model?.disabled ?? true) {
                        try object.draw(renderEncoder: renderEncoder, modelMatrix: object.modelMatrix(), frame: frame)
                    }
                }
            }
        }
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
        metalKitView: MTKView
    ) throws -> MTLRenderPipelineState {
        /// Build a render state pipeline object
        
        let vertexDescriptor = BillboardPipeline.buildVertexDescriptor()
        
        let library = device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "billboardVertexShader")
        let fragmentFunction = library?.makeFunction(name: "billboardFragmentShader")
        
        if vertexFunction == nil || fragmentFunction == nil {
             throw Errors.makeFunctionError
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "BillboardPipeline"
        pipelineDescriptor.rasterSampleCount = metalKitView.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}
