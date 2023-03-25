//
//  AlbedoLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

class AlbedoLayer: MaterialLayer {
    var color = Vec4(1.0, 1.0, 1.0, 1.0)
    
    override init() {
        super.init()
    }

    enum CodingKeys: CodingKey {
        case color
    }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        color = try container.decode(Vec4.self, forKey: .color)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(color, forKey: .color)
        
        try super.encode(to: encoder)
    }
}
