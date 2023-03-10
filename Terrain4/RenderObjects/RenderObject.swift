//
//  RenderObject.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import Metal

class RenderObject: Object {
    func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: matrix_float4x4) throws {
        throw Errors.notImplemented
    }
}
