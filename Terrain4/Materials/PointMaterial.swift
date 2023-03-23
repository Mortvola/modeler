//
//  PointMaterial.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import MetalKit

class PointMaterial {
    var objects: [Point] = []
    
    init(device: MTLDevice, view:  MTKView, descriptor: MaterialDescriptor?) {
        
    }

    func prepare(renderEncoder: MTLRenderCommandEncoder) {
//        renderEncoder.setFragmentTextures(self.textures, range: 0..<textures.count)
    }
}
