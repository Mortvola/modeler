//
//  PbrObject.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import Metal

class PbrObject: RenderObject {
    var uniforms: MTLBuffer?

    init(model: Model) {
        super.init(model: model)
        allocateUniformsBuffer()
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        allocateUniformsBuffer()
    }

    func allocateUniformsBuffer() {
        self.uniforms = Renderer.shared.device!.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
        self.uniforms!.label = "Node Uniforms"
    }
    
    func getUniformsBuffer(index: Int) -> UnsafeMutablePointer<NodeUniforms> {
        UnsafeMutableRawPointer(self.uniforms!.contents())
            .advanced(by: index * alignedNodeUniformsSize)
            .bindMemory(to: NodeUniforms.self, capacity: 1)
    }    
}
