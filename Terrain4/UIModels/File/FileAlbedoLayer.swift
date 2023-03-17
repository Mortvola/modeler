//
//  AlbedoLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

extension File {
    class AlbedoLayer: MaterialLayer {
        var color = Vec4(1.0, 1.0, 1.0, 1.0)
        
        init(albedo: Terrain4.AlbedoLayer) {
            self.color = albedo.color
            
            super.init(layer: albedo)
        }
        
        enum CodingKeys: CodingKey {
            case color
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            color = try container.decodeIfPresent(Vec4.self, forKey: .color) ?? Vec4(1.0, 1.0, 1.0, 1.0)
            
            try super.init(from: decoder)
        }
        
        override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(color, forKey: .color)
            
            try super.encode(to: encoder)
        }
    }
}
