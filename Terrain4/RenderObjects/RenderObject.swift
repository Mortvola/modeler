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
    
    var materialId: UUID?
    @Published var material: PbrMaterial?

    @MainActor
    func setMaterial(materialId: UUID?) {
        if materialId != self.material?.id {
            // Remove object from current material object list
            if let materialEntry = MaterialManager.shared.materials[self.material?.id] {
                let index = materialEntry.objects.firstIndex {
                    $0.id == self.id
                }
                
                if let index = index {
                    materialEntry.objects.remove(at: index)
                }
            }
            
            let materialEntry = MaterialManager.shared.materials[materialId]
            
            materialEntry?.objects.append(self)
            material = materialId != nil ? materialEntry?.material : nil
        }
    }
    
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
        
        materialId = try container.decode(UUID?.self, forKey: .material)
        
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(material?.id, forKey: .material)
    }
}
