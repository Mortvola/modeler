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
        
    func addMaterial(pbrMaterial: PbrMaterial) {
        let materialKey = pbrMaterial.id
        
        if materials[materialKey] == nil {
            materials[materialKey] = pbrMaterial
        }
    }
    
    func prepareObject(object: RenderObject) {
        object.uniformsSize = alignedNodeUniformsSize
        object.uniforms = Renderer.shared.device!.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
        object.uniforms!.label = "Node Uniforms"
    }
    
    func draw(object: RenderObject, renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, pbrProperties: PbrProperties?, frame: Int) throws {
        // Pass the normal matrix (derived from the model matrix) to the vertex shader
        var normalMatrix = matrix_float3x3(columns: (
            vector_float3(modelMatrix[0][0], modelMatrix[0][1], modelMatrix[0][2]),
            vector_float3(modelMatrix[1][0], modelMatrix[1][1], modelMatrix[1][2]),
           vector_float3(modelMatrix[2][0], modelMatrix[2][1], modelMatrix[2][2])
        ));
        
        normalMatrix = normalMatrix.inverse.transpose;

        let u: UnsafeMutablePointer<NodeUniforms> = object.getUniformsBuffer(index: frame)
        u[0].normalMatrix = normalMatrix

        // Pass the light information
        u[0].numberOfLights = Int32(object.lights.count)
        
        withUnsafeMutableBytes(of: &u[0].lights) { rawPtr in
            let light = rawPtr.baseAddress!.assumingMemoryBound(to: Lights.self)

            for i in 0..<object.lights.count {
                light[i].position = object.lights[i].position
                light[i].intensity = object.lights[i].intensity
            }
        }

        u[0].albedo = pbrProperties?.albedo ?? Vec3(1.0, 1.0, 1.0)
        u[0].normals = pbrProperties?.normal ?? Vec3(0.5, 0.5, 1.0)
        u[0].metallic = pbrProperties?.metallic ?? 1.0
        u[0].roughness = pbrProperties?.roughness ?? 1.0

        renderEncoder.setVertexBuffer(object.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)
        renderEncoder.setFragmentBuffer(object.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)

        try object.simpleDraw(renderEncoder: renderEncoder, modelMatrix: modelMatrix, frame: frame)
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
                        try self.draw(object: renderObject, renderEncoder: renderEncoder, modelMatrix: renderObject.modelMatrix(), pbrProperties: pbrProperties, frame: frame)
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
