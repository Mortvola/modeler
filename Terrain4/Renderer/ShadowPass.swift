//
//  ShadowPass.swift
//  Terrain4
//
//  Created by Richard Shields on 3/28/23.
//

import Foundation
import Metal

extension Renderer {
    public func shadowRenderModel(model: Model, renderEncoder: MTLRenderCommandEncoder) throws {
        if !model.disabled {
            for object in model.objects {
                switch object.content {
                case .model:
                    break
                case .mesh(let mesh):
                    if !mesh.disabled && mesh.instanceData.count > 0 {
                        let (buffer, offset) = mesh.getInstanceData(frame: self.uniformBufferIndex)
                        renderEncoder.setVertexBuffer(buffer, offset: offset, index: BufferIndex.modelMatrix.rawValue)

                        try mesh.draw(renderEncoder: renderEncoder)
                    }
                case .wireBox:
                    break
                case .point:
                    break
                case .light:
                    break
                case .directionalLight:
                    break
                }
            }
        }
    }
    
    func renderShadowPass(commandBuffer: MTLCommandBuffer) throws {
        if let renderPassDescriptor = objectStore!.currentScene!.directionalLight?.renderPassDescriptor {
            
            for cascade in 0..<shadowMapCascades {
                renderPassDescriptor.depthAttachment.slice = cascade
                
                guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                    return
                }
                
                renderEncoder.label = "Shadow Pass \(cascade)"
                
                //        renderEncoder.pushDebugGroup("Shadow Pass")
                
                renderEncoder.setFrontFacing(.clockwise)
                renderEncoder.setCullMode(.front)
                renderEncoder.setDepthClipMode(.clamp) // Pancaking??
                renderEncoder.setDepthStencilState(self.shadowDepthState)
                renderEncoder.setDepthBias(self.depthBias, slopeScale: self.slopeScale, clamp: self.slopeScale)
                
                //            let viewport = MTLViewport(originX: 0, originY: 0, width: Double(objectStore!.directionalLight.shadowTexture!.width), height: Double(objectStore!.directionalLight.shadowTexture!.height), znear: 0.0, zfar: 1.0)
                //            renderEncoder.setViewport(viewport)
                //        renderEncoder.setDepthBias(0.015, slopeScale: 7, clamp: 0.02)
                
                renderEncoder.setVertexBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.frameConstants.rawValue)
                
                renderEncoder.setVertexBuffer(self.shadowCascadeMatricesBuffer, offset: self.shadowCascadeMatricesOffset, index: BufferIndex.shadowCascadeMatrices.rawValue)

                var cascadeIndex = Int32(cascade)
                renderEncoder.setVertexBytes(&cascadeIndex, length: MemoryLayout<Int32>.size, index: BufferIndex.cascadeIndex.rawValue)
                
                if objectStore!.currentScene?.directionalLight?.shadowCaster ?? false {
                    pipelineManager.depthShadowPipeline.prepare(renderEncoder: renderEncoder)
                    
                    if let scene = objectStore?.currentScene {
                        for sceneModel in scene.models {
                            try shadowRenderModel(model: sceneModel.model!, renderEncoder: renderEncoder)
                        }
                    }
                }
                
                //        renderEncoder.popDebugGroup()
                
                renderEncoder.endEncoding()
            }
        }
    }
}
