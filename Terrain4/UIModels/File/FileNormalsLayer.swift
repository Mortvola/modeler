//
//  NormalsLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

extension File {
    class NormalsLayer: MaterialLayer {
        var normal = Vec4(0.0, 0.0, 1.0, 1.0)
        
        init(normals: Terrain4.NormalsLayer) {
            self.normal = normals.normal
            
            super.init(layer: normals)
        }
        
        enum CodingKeys: CodingKey {
            case normal
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            normal = try container.decodeIfPresent(Vec4.self, forKey: .normal) ?? Vec4(0.0, 0.0, 1.0, 1.0)
            
            try super.init(from: decoder)
        }
        
        override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(normal, forKey: .normal)
            
            try super.encode(to: encoder)
        }
    }
}
