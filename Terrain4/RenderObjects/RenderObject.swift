//
//  RenderObject.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import Metal

let alignedNodeUniformsSize = MemoryLayout<NodeUniforms>.size // (MemoryLayout<NodeUniforms>.size + 0xFF) & -0x100

class RenderObject: Object {
    // lights that may affect this object.
    var lights: [Light] = []
    var materialId: UUID?
    @Published var material: MaterialWrapper?
    
    override init(model: Model?) {
        super.init(model: model)
    }
    
    enum CodingKeys: CodingKey {
        case material
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        materialId = try container.decodeIfPresent(UUID.self, forKey: .material)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(material?.id, forKey: .material)
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, pbrProperties: PbrProperties?, frame: Int) throws {
        throw Errors.notImplemented
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        throw Errors.notImplemented
    }

    func simpleDraw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        throw Errors.notImplemented
    }
    
    @MainActor
    func setMaterial(materialId: UUID?) {
        // Process if there is a change or if the material is not set
        if materialId != self.material?.id || material == nil {
            Renderer.shared.materialManager.removeObjectFromMaterial(object: self, materialId: self.materialId)
            
            Renderer.shared.materialManager.addObjectToMaterial(object: self, materialId: materialId)
        }
    }    
}
