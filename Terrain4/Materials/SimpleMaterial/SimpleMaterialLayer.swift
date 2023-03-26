//
//  SimpleMaterialLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/24/23.
//

import Foundation
import Metal

enum LayerWrapper: Codable {
    case color(Vec4)
    case monoColor(Float)
    case texture(Texture)
    
    var id: UUID {
        switch self {
        case .color(let l):
            break
        case .monoColor(let l):
            break
        case .texture(let l):
            return l.id
        }
        
        return UUID()
    }

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
            self = LayerWrapper.color(color)
        }
        else if (container.contains(.monoColor)) {
            let monoColor = try container.decode(Float.self, forKey: .monoColor)
            self = LayerWrapper.monoColor(monoColor)
        }
        else if (container.contains(.texture)) {
            let texture = try container.decode(Texture.self, forKey: .texture)
            self = LayerWrapper.texture(texture)
        }
        else {
            throw Errors.invalidTexture
        }
    }
}

class Texture: ObservableObject, Codable {
    let id = UUID()
    
    @Published var filename: String
    var texture: MTLTexture?
    
    init() {
        filename = ""
    }
    
    @MainActor
    func setTexture(file: String?) async {
        if file != filename {
            filename = file ?? ""
            await loadTexture()
        }
    }

    private func loadTexture() async {
        if !filename.isEmpty {
            texture = try? await TextureManager.shared.addTexture(path: filename)
        }
    }

    enum CodingKeys: CodingKey {
        case filename
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        filename = try container.decode(String.self, forKey: .filename)
        
        let t = Task {
            await self.loadTexture()
        }
        
        decoder.addTask(t)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(filename, forKey: .filename)
    }
}
