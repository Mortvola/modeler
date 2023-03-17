//
//  AlbedoLayerDescriptor.swift
//  Terrain4
//
//  Created by Richard Shields on 3/17/23.
//

import Foundation

class AlbedoLayerDescriptor: MaterialLayerDescriptor {
    var color: Vec4
    
    override init() {
        color = Vec4(1.0, 1.0, 1.0, 1.0)
        
        super.init()
    }
    
    init(albedoLayer: AlbedoLayer) {
        self.color = albedoLayer.color
        
        super.init(materialLayer: albedoLayer)
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
