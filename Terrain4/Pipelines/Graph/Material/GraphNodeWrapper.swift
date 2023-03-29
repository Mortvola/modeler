//
//  LayerWrapper.swift
//  Terrain4
//
//  Created by Richard Shields on 3/26/23.
//

import Foundation

enum GraphNodeWrapper: Codable {
    case color(GraphNodeColor)
    case texture(GraphNodeTexture)
    case add(GraphNodeAdd)
    
    var id: UUID {
        switch self {
        case .color(let n):
            return n.id
        case .texture(let n):
            return n.id
        case .add(let n):
            return n.id
        }
    }

    enum CodingKeys: CodingKey {
        case type
        case color
        case texture
        case add
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .color(let c):
            try container.encode("Color", forKey: .type)
            try container.encode(c, forKey: .color)
        case .texture(let t):
            try container.encode("Add", forKey: .type)
            try container.encode(t, forKey: .texture)
        case .add(let n):
            try container.encode("Add", forKey: .type)
            try container.encode(n, forKey: .add)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.color) {
            let color = try container.decode(GraphNodeColor.self, forKey: .color)
            self = GraphNodeWrapper.color(color)
        }
        else if (container.contains(.texture)) {
            let texture = try container.decode(GraphNodeTexture.self, forKey: .texture)
            self = GraphNodeWrapper.texture(texture)
        }
        else if (container.contains(.add)) {
            let add = try container.decode(GraphNodeAdd.self, forKey: .add)
            self = GraphNodeWrapper.add(add)
        }
        else {
            throw Errors.invalidTexture
        }
    }
}

