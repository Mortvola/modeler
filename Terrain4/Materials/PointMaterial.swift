//
//  PointMaterial.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import MetalKit

class PointMaterial: Material {
//    init(device: MTLDevice, view:  MTKView, descriptor: MaterialDescriptor?) {
//        super.init(name: "Point Material")
//    }

    override func prepare(renderEncoder: MTLRenderCommandEncoder, frame: Int) {
        if let texture = Renderer.shared.textureStore?.texture {
            renderEncoder.setFragmentTexture(texture, index: TextureIndex.color.rawValue)
        }
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try container.decode(String.self, forKey: .name)
        
        super.init(name: name)
        
        id = try container.decode(UUID.self, forKey: .id)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
}
