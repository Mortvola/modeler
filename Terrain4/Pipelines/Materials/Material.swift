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
    var transparent: Bool = false

    func prepare(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        throw Errors.notImplemented
    }
    
    override init(name: String) {
        super.init(name: name)
    }

    func clearDrawables() {
        objects = []
    }
    
    func pipelineType() throws -> PipelineType {
        throw Errors.notImplemented
    }
    
    func addObject(object: RenderObject) throws {
        let index = objects.firstIndex {
            $0.id == object.id
        }

        if index == nil {
            objects.append(object)
            try Renderer.shared.pipelineManager.addMaterial(self, using: try pipelineType(), on: object)
        }
    }
    
    func removeObject(object: RenderObject) {
        let index = objects.firstIndex {
            $0.id == object.id
        }
        
        if let index = index {
            objects.remove(at: index)
        }
    }

    enum CodingKeys: CodingKey {
        case id
        case transparent
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        transparent = try container.decodeIfPresent(Bool.self, forKey: .transparent) ?? false
        
        try super.init(from: decoder)
        
        id = try container.decode(UUID.self, forKey: .id)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        
        try container.encode(transparent, forKey: .transparent)
        
        try super.encode(to: encoder)
    }
}
