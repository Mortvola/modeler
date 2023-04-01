//
//  MainPass.swift
//  Terrain4
//
//  Created by Richard Shields on 3/28/23.
//

import Foundation
import Metal

extension Renderer {
    func renderMainPass(renderEncoder: MTLRenderCommandEncoder) throws {
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
        
//            renderEncoder.popDebugGroup()        
    }
}
