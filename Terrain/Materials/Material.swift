//
//  Material.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import Metal

protocol Material {
    func getPipeline() -> MTLRenderPipelineState
    
    func prepare(renderEncoder: MTLRenderCommandEncoder)
}
