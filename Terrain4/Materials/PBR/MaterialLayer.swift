//
//  MaterialLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation
import Metal

class MaterialLayer: Codable {
    var map = ""
    var texture: MTLTexture? = nil
    var useSimple = false
    
    init() {}
    
    enum CodingKeys: CodingKey {
        case map
        case useSimple
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        map = try container.decode(String.self, forKey: .map)
        useSimple = try container.decode(Bool.self, forKey: .useSimple)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(map, forKey: .map)
        try container.encode(useSimple, forKey: .useSimple)
    }
}
