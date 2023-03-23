//
//  RenderObject.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import Metal

let alignedNodeUniformsSize = MemoryLayout<NodeUniforms>.size // (MemoryLayout<NodeUniforms>.size + 0xFF) & -0x100

class RenderObject: Object {
    // lights that may affect this object.
    var lights: [Light] = []
        
    override init(model: Model?) {
        super.init(model: model)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, pbrProperties: PbrProperties?, frame: Int) throws {
        throw Errors.notImplemented
    }
    
    func simpleDraw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        throw Errors.notImplemented
    }
}
