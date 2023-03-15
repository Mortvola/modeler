//
//  RenderObject.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import Metal

class RenderObject: Object {
    // lights that may affect this object.
    var lights: [Light] = []
    
    @Published var material: Material?

    override init(model: Model) {
        super.init(model: model)
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4) throws {
        throw Errors.notImplemented
    }
    
    enum CodingKeys: CodingKey {
        case material
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(UUID?.self, forKey: .material)
        
        material = MaterialStore.shared.materials.first { m in
            m.id == id
        }
    
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(material?.id, forKey: .material)
    }
}
