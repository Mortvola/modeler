//
//  PbrPipeline.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import Metal
import MetalKit

class PbrPipeline {
    let pipeline: MTLRenderPipelineState
    let samplerState: MTLSamplerState

    var materials: [UUID?:PbrMaterial] = [:]
    
    init(device: MTLDevice, view: MTKView) throws {
        pipeline = try PbrPipeline.buildPipeline(device: device, view: view)
        samplerState = PbrPipeline.buildSamplerState(device: device)
    }
    
//    func addMaterial() async throws {
//        let materialDescriptor = MaterialDescriptor()
//        
//        materialDescriptor.name = "Material_0"
//        
//        _ = try await addMaterial(device: Renderer.shared.device!, view: Renderer.shared.view!, descriptor: materialDescriptor)
//    }
    
//    func addMaterial(device: MTLDevice, view: MTKView, descriptor: MaterialDescriptor?) async throws -> PbrMaterial {
//        let materialKey = descriptor?.id
//
//        if let pbrMaterial = self.materials[materialKey] {
//            return pbrMaterial
//        }
//
//        let material = try await PbrMaterial(device: device, view: view, descriptor: descriptor)
//
//        self.materials[materialKey] = material
//
//        return material
//    }
    
    func addMaterial(pbrMaterial: PbrMaterial) {
        let materialKey = pbrMaterial.id
        
        if materials[materialKey] == nil {
            materials[materialKey] = pbrMaterial
        }
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        renderEncoder.setRenderPipelineState(pipeline)
        renderEncoder.setFragmentSamplerState(samplerState, index: SamplerIndex.sampler.rawValue)
        
        for (_, material) in self.materials {
            if material.objects.count > 0 {
                material.prepare(renderEncoder: renderEncoder)
                let pbrProperties = material.getPbrProperties()
                
                for renderObject in material.objects {
                    if !renderObject.disabled && !(renderObject.model?.disabled ?? true) {
                        try renderObject.draw(renderEncoder: renderEncoder, modelMatrix: renderObject.modelMatrix(), pbrProperties: pbrProperties, frame: frame)
                    }
                }
            }
        }
    }
    
    class func buildVertexDescriptor() -> MTLVertexDescriptor {
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
    
    class func buildPipeline(
        device: MTLDevice,
        view: MTKView
    ) throws -> MTLRenderPipelineState {
        let vertexDescriptor = PbrPipeline.buildVertexDescriptor()
        
        let library = device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "pbrVertexShader")
        let fragmentFunction = library?.makeFunction(name: "pbrFragmentShader")
        
        if vertexFunction == nil || fragmentFunction == nil {
            throw Errors.makeFunctionError
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "PbrPipeline"
        pipelineDescriptor.rasterSampleCount = view.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        //        pipelineDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private class func buildSamplerState(device: MTLDevice) -> MTLSamplerState {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        return device.makeSamplerState(descriptor: samplerDescriptor)!
    }
}
