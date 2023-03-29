//
//  RoughnessLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

class RoughnessLayer: MaterialLayer {
    var value: Float = 1.0
    
    override init() {
        super.init()
    }

    enum CodingKeys: CodingKey {
        case value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        value = try container.decode(Float.self, forKey: .value)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(value, forKey: .value)
        
        try super.encode(to: encoder)
    }
}
