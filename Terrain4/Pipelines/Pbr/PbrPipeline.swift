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
    init() {
        super.init(type: .pbrPipeline)
    }
    
    override func initialize(transparent: Bool) throws {
        pipeline = try buildPipeline(
            name: "PbrPipeline",
            vertexShader: "pbrVertexShader",
            fragmentShader: transparent ? "pbrFragmentTransparencyShader" : "pbrFragmentShader",
            transparent: transparent
        )
    }

    override func prepareObject(object: RenderObject) {
        object.uniformsSize = alignedNodeUniformsSize
        object.uniforms = MetalView.shared.device.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
        object.uniforms!.label = "Node Uniforms"
    }
    
    override func draw(object: RenderObject, renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        if object.instanceData.count > 0 {
            let u: UnsafeMutablePointer<NodeUniforms> = object.getUniformsBuffer(index: frame)
            
            // Pass the light information
            u[0].numberOfLights = Int32(Renderer.shared.objectStore!.currentScene!.lights.count)
            
            withUnsafeMutableBytes(of: &u[0].lights) { rawPtr in
                let light = rawPtr.baseAddress!.assumingMemoryBound(to: Lights.self)
                
                for i in 0..<Renderer.shared.objectStore!.currentScene!.lights.count {
                    light[i].position = Renderer.shared.objectStore!.currentScene!.lights[i].position
                    light[i].intensity = Renderer.shared.objectStore!.currentScene!.lights[i].intensity
                }
            }
            
            let (buffer, offset) = object.getInstanceData(frame: frame)
            renderEncoder.setVertexBuffer(buffer, offset: offset, index: BufferIndex.modelMatrix.rawValue)
            
            renderEncoder.setVertexBuffer(object.uniforms, offset: frame * object.uniformsSize, index: BufferIndex.nodeUniforms.rawValue)
            renderEncoder.setFragmentBuffer(object.uniforms, offset: frame * object.uniformsSize, index: BufferIndex.nodeUniforms.rawValue)
            
            try object.draw(renderEncoder: renderEncoder)
        }
    }    
}
