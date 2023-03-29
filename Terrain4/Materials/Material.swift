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

    func prepare(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        throw Errors.notImplemented
    }
    
    override init(name: String) {
        super.init(name: name)
    }

    func clearDrawables() {
        objects = []
    }
    
    func addObject(object: RenderObject) {
        let index = objects.firstIndex {
            $0.id == object.id
        }

        if index == nil {
            objects.append(object)
            updatePipeline(object: object)
        }
    }
    
    private func updatePipeline(object: RenderObject) {
        switch object.material! {
        case .pbrMaterial:
            Renderer.shared.pipelineManager.pbrPipeline.addMaterial(material: object.material!)
            Renderer.shared.pipelineManager.pbrPipeline.prepareObject(object: object)
        case .billboardMaterial:
            break //m.objects.append(self)
        case .pointMaterial:
            break //m.objects.append(self)
        case .graphMaterial:
            Renderer.shared.pipelineManager.graphPipeline.addMaterial(material: object.material!)
            Renderer.shared.pipelineManager.graphPipeline.prepareObject(object: object)
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
