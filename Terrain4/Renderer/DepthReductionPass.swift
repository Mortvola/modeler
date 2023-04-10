//
//  DepthReductionPass.swift
//  Terrain4
//
//  Created by Richard Shields on 4/5/23.
//

import Foundation
import Metal
import MetalKit

extension Renderer {
    func allocateReductionBuffer(numTiles: Int) throws {
        guard let buffer = MetalView.shared.device.makeBuffer(length: numTiles * MemoryLayout<Vec2>.size, options: [MTLResourceOptions.storageModePrivate]) else {
            throw Errors.makeBufferFailed
        }
        
        buffer.label = "Depth Reductions"
        self.depthReductionBuffer = buffer

        guard let buffer = MetalView.shared.device.makeBuffer(length: MemoryLayout<Vec2>.size, options: [MTLResourceOptions.storageModeShared]) else {
            throw Errors.makeBufferFailed
        }
        
        buffer.label = "Depth Reduction Final"
        self.depthReductionFinalBuffer = buffer
    }
    
    func renderDepthReductionPass(view: MTKView, commandBuffer: MTLCommandBuffer) throws {
        let optimalTileSize = MTLSizeMake(Int(kTileWidth), Int(kTileHeight), 1) // TODO: determine what this should be

        let renderPassDescriptor = MTLRenderPassDescriptor()
        
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .dontCare
        renderPassDescriptor.depthAttachment.clearDepth = 1.0
        renderPassDescriptor.colorAttachments[0].texture = self.depthReductionTexture!
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .dontCare
        renderPassDescriptor.depthAttachment.texture = self.depthTexture!

        renderPassDescriptor.tileWidth = optimalTileSize.width
        renderPassDescriptor.tileHeight = optimalTileSize.height

        if (self.depthReductionBuffer == nil) {
            let numTilesX = (renderPassDescriptor.colorAttachments[0].texture!.width + optimalTileSize.width - 1) / optimalTileSize.width
            let numTilesY = (renderPassDescriptor.colorAttachments[0].texture!.height + optimalTileSize.height - 1) / optimalTileSize.height
            let numTiles = numTilesX * numTilesY

            try allocateReductionBuffer(numTiles: numTiles)
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.label = "Depth Reduction Pass"
            
        // Clear out the transparent fragment stores.
        renderEncoder.setTileBuffer(self.depthReductionBuffer, offset: 0, index: BufferIndex.reduction.rawValue)
        renderEncoder.setTileBuffer(self.depthReductionFinalBuffer, offset: 0, index: BufferIndex.finalReduction.rawValue)
        renderEncoder.setRenderPipelineState(pipelineManager.depthReductionInitPipeline!)
        renderEncoder.dispatchThreadsPerTile(MTLSizeMake(1, 1, 1))

        renderEncoder.pushDebugGroup("Depth Reduction Pass")
        
        renderEncoder.setFrontFacing(.clockwise)
        renderEncoder.setCullMode(.back)
        renderEncoder.setDepthClipMode(.clamp) // Pancaking??
        renderEncoder.setDepthStencilState(self.shadowDepthState)
        renderEncoder.setDepthBias(self.depthBias, slopeScale: self.slopeScale, clamp: self.slopeScale)

        renderEncoder.setVertexBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.frameConstants.rawValue)
        renderEncoder.setTileBuffer(self.dynamicUniformBuffer, offset: self.uniformBufferOffset, index: BufferIndex.frameConstants.rawValue)

        // Render objects in scene.
        if objectStore!.currentScene?.directionalLight?.shadowCaster ?? false {
            pipelineManager.depthReductionPipeline.prepare(renderEncoder: renderEncoder)

            if let scene = objectStore?.currentScene {
                for sceneModel in scene.models {
                    try shadowRenderModel(model: sceneModel.model!, renderEncoder: renderEncoder)
                }
            }
        }

        renderEncoder.setRenderPipelineState(pipelineManager.depthReductionMinMaxPipeline!)
        renderEncoder.dispatchThreadsPerTile(MTLSizeMake(8, 8, 1))

        renderEncoder.setTileBuffer(self.shadowCascadeMatricesBuffer, offset: 0, index: BufferIndex.shadowCascadeMatrices.rawValue)
        renderEncoder.setTileBuffer(depthReductionBuffer, offset: 0, index: BufferIndex.reduction.rawValue)
        renderEncoder.setRenderPipelineState(pipelineManager.depthReductionFinalizePipeline!)
        renderEncoder.dispatchThreadsPerTile(MTLSizeMake(1, 1, 1))

        renderEncoder.popDebugGroup()
        
        renderEncoder.endEncoding()
    }

}
