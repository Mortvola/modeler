//
//  MaterialLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation
import Metal

class MaterialLayer: ObservableObject, Codable {
    @Published var map = ""
    var texture: MTLTexture? = nil
    var useSimple = false
    
    init() {}
    
    @MainActor
    func setTexture(file: String?) async {
        map = file ?? ""
        await loadTexture()
    }
    
    private func loadTexture() async {
        if !map.isEmpty {
            texture = try? await TextureManager.shared.addTexture(path: map)
        }
    }

    enum CodingKeys: CodingKey {
        case map
        case useSimple
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        map = try container.decode(String.self, forKey: .map)
        useSimple = try container.decode(Bool.self, forKey: .useSimple)
        
        let t = Task {
            await self.loadTexture()
        }
        
        decoder.addTask(t)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(map, forKey: .map)
        try container.encode(useSimple, forKey: .useSimple)
    }
}
