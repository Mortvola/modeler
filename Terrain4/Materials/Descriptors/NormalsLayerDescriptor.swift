//
//  NormalsLayerDescriptor.swift
//  Terrain4
//
//  Created by Richard Shields on 3/17/23.
//

import Foundation

class NormalsLayerDescriptor: MaterialLayerDescriptor {
    var normal: Vec4
    
    override init() {
        self.normal = Vec4(0.0, 0.0, 1.0, 1.0)
        
        super.init()
    }
    
    init(normalsLayer: NormalsLayer) {
        self.normal = normalsLayer.normal
        
        super.init(materialLayer: normalsLayer)
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
