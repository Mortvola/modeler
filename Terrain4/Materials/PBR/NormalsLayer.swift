//
//  NormalsLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

class NormalsLayer: MaterialLayer {
    var normal = Vec4(0.0, 0.0, 1.0, 1.0)
    
    override init() {
        super.init()
    }

    enum CodingKeys: CodingKey {
        case normal
    }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        normal = try container.decode(Vec4.self, forKey: .normal)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(normal, forKey: .normal)
        
        try super.encode(to: encoder)
    }
}
