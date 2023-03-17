//
//  RoughnessLayerDescriptor.swift
//  Terrain4
//
//  Created by Richard Shields on 3/17/23.
//

import Foundation

class RoughnessLayerDescriptor: MaterialLayerDescriptor {
    var value: Float
    
    override init() {
        self.value = 1.0
        
        super.init()
    }
    
    init(roughnessLayer: RoughnessLayer) {
        self.value = roughnessLayer.value
        
        super.init(materialLayer: roughnessLayer)
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
