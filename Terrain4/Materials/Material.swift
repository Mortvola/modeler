//
//  Material.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import Metal

class Material: Item {
    var id = UUID()
    var objects: [RenderObject] = []

    func prepare(renderEncoder: MTLRenderCommandEncoder) throws {
        throw Errors.notImplemented
    }
    
    override init(name: String) {
        super.init(name: name)
    }

    enum CodingKeys: CodingKey {
        case id
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        id = try container.decode(UUID.self, forKey: .id)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        
        try super.encode(to: encoder)
    }
}
