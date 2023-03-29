//
//  GraphNodeTexture.swift
//  Terrain4
//
//  Created by Richard Shields on 3/24/23.
//

import Foundation
import Metal

class GraphNodeTexture: GraphNode, ObservableObject {
    @Published var filename: String
    var texture: MTLTexture?
    
    override init() {
        filename = ""
        
        super.init()
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
        
        try super.init(from: decoder)
        
        let t = Task {
            await self.loadTexture()
        }
        
        decoder.addTask(t)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(filename, forKey: .filename)
    }
}
