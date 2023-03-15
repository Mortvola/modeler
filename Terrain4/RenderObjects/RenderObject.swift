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
    public var materialEntry: MaterialManager.MaterialEntry?

    @MainActor
    func setMaterial(newMaterial: Material?) async throws {
        if newMaterial != self.material {
            if let materialEntry = materialEntry {
                let index = materialEntry.objects.firstIndex {
                    $0.id == self.id
                }
                
                if let index = index {
                    materialEntry.objects.remove(at: index)
                }
                
                self.materialEntry = nil
            }
            
            self.materialEntry = try await MaterialManager.shared.addMaterial(device: Renderer.shared.device!, view: Renderer.shared.view!, material: newMaterial)
            
            self.materialEntry?.objects.append(self)
            
            material = newMaterial
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
        
        let id = try container.decode(UUID?.self, forKey: .material)
        
        self.material = MaterialStore.shared.materials.first { m in
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
