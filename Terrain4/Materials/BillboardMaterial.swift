//
//  BillboardMaterial.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import MetalKit

class BillboardMaterial: Material {
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func prepare(renderEncoder: MTLRenderCommandEncoder, frame: Int) {
        if let texture = Renderer.shared.textureStore?.texture {
            renderEncoder.setFragmentTexture(texture, index: TextureIndex.color.rawValue)
        }
    }
}
