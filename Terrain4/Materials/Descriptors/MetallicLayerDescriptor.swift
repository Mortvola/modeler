//
//  MetallicLayerDescriptor.swift
//  Terrain4
//
//  Created by Richard Shields on 3/17/23.
//

import Foundation

class MetallicLayerDescriptor: MaterialLayerDescriptor {
    var value: Float
    
    override init() {
        value = 1.0
        
        super.init()
    }
    
    init(metallicLayer: MetallicLayer) {
        self.value = metallicLayer.value
        
        super.init(materialLayer: metallicLayer)
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
