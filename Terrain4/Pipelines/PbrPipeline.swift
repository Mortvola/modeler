//
//  PbrPipeline.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import Metal
import MetalKit

class PbrPipeline: Pipeline {
    var pipeline: MTLRenderPipelineState? = nil

    func initialize() throws {
        pipeline = try buildPipeline(name: "PbrPipeline", vertexShader: "pbrVertexShader", fragmentShader: "pbrFragmentShader")
    }
        
    func prepareObject(object: RenderObject) {
        object.uniformsSize = alignedNodeUniformsSize
        object.uniforms = MetalView.shared.device.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
        object.uniforms!.label = "Node Uniforms"
    }
    
    func draw(object: RenderObject, renderEncoder: MTLRenderCommandEncoder, pbrProperties: PbrProperties?, frame: Int) throws {
        if object.instanceData.count > 0 {
            // Pass the normal matrix (derived from the model matrix) to the vertex shader
            let modelMatrix = object.instanceData[0].transformation
            
            var normalMatrix = matrix_float3x3(columns: (
                vector_float3(modelMatrix[0][0], modelMatrix[0][1], modelMatrix[0][2]),
                vector_float3(modelMatrix[1][0], modelMatrix[1][1], modelMatrix[1][2]),
                vector_float3(modelMatrix[2][0], modelMatrix[2][1], modelMatrix[2][2])
            ));
            
            normalMatrix = normalMatrix.inverse.transpose;
            
            let u: UnsafeMutablePointer<NodeUniforms> = object.getUniformsBuffer(index: frame)
            u[0].normalMatrix = normalMatrix
            
            // Pass the light information
            u[0].numberOfLights = Int32(Renderer.shared.objectStore!.currentScene!.lights.count)
            
            withUnsafeMutableBytes(of: &u[0].lights) { rawPtr in
                let light = rawPtr.baseAddress!.assumingMemoryBound(to: Lights.self)
                
                for i in 0..<Renderer.shared.objectStore!.currentScene!.lights.count {
                    light[i].position = Renderer.shared.objectStore!.currentScene!.lights[i].position
                    light[i].intensity = Renderer.shared.objectStore!.currentScene!.lights[i].intensity
                }
            }
            
            renderEncoder.setVertexBuffer(object.uniforms, offset: frame * object.uniformsSize, index: BufferIndex.nodeUniforms.rawValue)
            renderEncoder.setFragmentBuffer(object.uniforms, offset: frame * object.uniformsSize, index: BufferIndex.nodeUniforms.rawValue)
            
            try object.draw(renderEncoder: renderEncoder, frame: frame)
        }
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        renderEncoder.setRenderPipelineState(pipeline!)
        
        for (_, material) in self.materials {
            if material.material.objects.count > 0 {
                switch material {
                case .pbrMaterial(let material):
                    material.prepare(renderEncoder: renderEncoder, frame: frame)
                    let pbrProperties = material.getPbrProperties()
                    
                    for renderObject in material.objects {
                        if !renderObject.disabled && !(renderObject.model?.disabled ?? true) {
                            try self.draw(object: renderObject, renderEncoder: renderEncoder, pbrProperties: pbrProperties, frame: frame)
                        }
                    }

                default:
                    break
                }
            }
        }
    }    
}
