//
//  RenderObject.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import Metal

protocol RenderObject {
    func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: matrix_float4x4)
    
    func modelMatrix() -> matrix_float4x4
}
