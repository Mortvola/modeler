//
//  SimpleMaterialLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/24/23.
//

import Foundation
import Metal

enum LayerContent: Codable {
    case color(Vec4)
    case monoColor(Float)
    case texture(Texture)
    
    enum CodingKeys: CodingKey {
        case color
        case monoColor
        case texture
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .color(let c):
            try container.encode(c, forKey: .color)
        case .monoColor(let m):
            try container.encode(m, forKey: .monoColor)
        case .texture(let t):
            try container.encode(t, forKey: .texture)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.color) {
            let color = try container.decode(Vec4.self, forKey: .color)
            self = LayerContent.color(color)
        }
        else if (container.contains(.monoColor)) {
            let monoColor = try container.decode(Float.self, forKey: .monoColor)
            self = LayerContent.monoColor(monoColor)
        }
        else if (container.contains(.texture)) {
            let texture = try container.decode(Texture.self, forKey: .texture)
            self = LayerContent.texture(texture)
        }
        else {
            throw Errors.invalidTexture
        }
    }
}

struct Texture: Codable {
    var filename: String
    var texture: MTLTexture?
    
    enum CodingKeys: CodingKey {
        case filename
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        filename = try container.decode(String.self, forKey: .filename)
    }
}
