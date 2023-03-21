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

    var uniforms: MTLBuffer?
    
    @MainActor
    func setMaterial(materialId: UUID?) {
        // Process if there is a change or if the material is not set
        if materialId != self.material?.id || material == nil {
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
    
    override init(model: Model?) {
        super.init(model: model)
        allocateUniformsBuffer()
    }

    func allocateUniformsBuffer() {
        self.uniforms = Renderer.shared.device!.makeBuffer(length: 3 * MemoryLayout<NodeUniforms>.size, options: [MTLResourceOptions.storageModeShared])!
        self.uniforms!.label = "node uniforms"
    }
    
    func getUniformsBuffer(index: Int) -> UnsafeMutablePointer<NodeUniforms> {
        UnsafeMutableRawPointer(self.uniforms!.contents())
            .advanced(by: index * MemoryLayout<NodeUniforms>.stride)
            .bindMemory(to: NodeUniforms.self, capacity: 1)
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        throw Errors.notImplemented
    }
    
    func simpleDraw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        throw Errors.notImplemented
    }
    
    enum CodingKeys: CodingKey {
        case material
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        materialId = try container.decode(UUID?.self, forKey: .material)
        
        try super.init(from: decoder)
        
        allocateUniformsBuffer()
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(material?.id, forKey: .material)
    }
}
