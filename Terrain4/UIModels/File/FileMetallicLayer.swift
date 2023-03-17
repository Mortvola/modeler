//
//  MetallicLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

extension File {
    class MetallicLayer: MaterialLayer {
        var value: Float = 1.0
        
        init(metallic: Terrain4.MetallicLayer) {
            self.value = metallic.value
            
            super.init(layer: metallic)
        }
        
        enum CodingKeys: CodingKey {
            case value
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            value = try container.decodeIfPresent(Float.self, forKey: .value) ?? 1.0
            
            try super.init(from: decoder)
        }
        
        override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(value, forKey: .value)
            
            try super.encode(to: encoder)
        }
    }
}
