//
//  TransparentPass.swift
//  Terrain4
//
//  Created by Richard Shields on 3/29/23.
//

import Foundation
import Metal

extension Renderer {
    func renderTransparentPass(renderEncoder: MTLRenderCommandEncoder) throws {
        /// Final pass rendering code here
        renderEncoder.label = "Transparent Render Encoder"
        
//            renderEncoder.pushDebugGroup("Main Pass")
        
        renderEncoder.setFrontFacing(.clockwise)
        renderEncoder.setCullMode(.none)
        renderEncoder.setDepthStencilState(self.transparentDepthState)

        renderEncoder.setVertexBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
        
        renderEncoder.setFragmentBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
        
        try pipelineManager.transparentRender(renderEncoder: renderEncoder, frame: self.uniformBufferIndex)
        
//            renderEncoder.popDebugGroup()        
    }
}
