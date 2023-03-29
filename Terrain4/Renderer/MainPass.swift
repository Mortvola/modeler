//
//  MainPass.swift
//  Terrain4
//
//  Created by Richard Shields on 3/28/23.
//

import Foundation
import Metal

extension Renderer {
    func renderMainPass(renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) throws {
        if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
            
            /// Final pass rendering code here
            renderEncoder.label = "Primary Render Encoder"
            
//            renderEncoder.pushDebugGroup("Main Pass")
            
            renderEncoder.setFrontFacing(.clockwise)
            renderEncoder.setCullMode(.back)
            renderEncoder.setDepthStencilState(self.depthState)
            
            renderEncoder.setVertexBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
            
            renderEncoder.setFragmentBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
            
            if let shadowTexture = objectStore!.currentScene?.directionalLight?.shadowTexture {
                renderEncoder.setFragmentTexture(shadowTexture, index: TextureIndex.depth.rawValue)
            }
            
            try pipelineManager.render(renderEncoder: renderEncoder, frame: self.uniformBufferIndex)
            objectStore!.skybox?.draw(renderEncoder: renderEncoder)
            
            // Render fustrum
            
//            if self.freezeFustrum {
//                self.lineMaterial?.prepare(renderEncoder: renderEncoder)
//
//                self.fustrums[self.uniformBufferIndex].updateVertices(points: objectStore!.directionalLight.cameraFustrum)
//                self.fustrums[self.uniformBufferIndex].draw(renderEncoder: renderEncoder, modelMatrix: Matrix4x4.identity(), pbrProperties: nil, frame: self.uniformBufferIndex)
//
//                self.lightFustrums[self.uniformBufferIndex].updateVertices(points: objectStore!.directionalLight.lightFustrum)
//                self.lightFustrums[self.uniformBufferIndex].draw(renderEncoder: renderEncoder, modelMatrix: Matrix4x4.identity(), pbrProperties: nil, frame: self.uniformBufferIndex)
//            }

//            renderEncoder.popDebugGroup()
            
            renderEncoder.endEncoding()
        }
    }
}
