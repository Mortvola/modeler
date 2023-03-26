//
//  SimpleMaterial.swift
//  Terrain4
//
//  Created by Richard Shields on 3/24/23.
//

import Foundation
import Metal
import MetalKit


class SimpleMaterial: Material {
    @Published var layers: [LayerWrapper] = []

    init() {
        super.init(name: "Simple Material")
    }

    func deleteLayer(id: UUID) {
        let index = layers.firstIndex {
            $0.id == id
        }
        
        if let index = index {
            layers.remove(at: index)
        }
    }
    
    override func prepare(renderEncoder: MTLRenderCommandEncoder) {
        for layer in layers {
            switch layer {
            case .texture(let l):
                renderEncoder.setFragmentTexture(l.texture, index: 0)
            default:
                break
            }
        }
    }
    
    enum CodingKeys: CodingKey {
        case layers
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        layers = try container.decode([LayerWrapper].self, forKey: .layers)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(layers, forKey: .layers)
        
        try super.encode(to: encoder)
    }
}
