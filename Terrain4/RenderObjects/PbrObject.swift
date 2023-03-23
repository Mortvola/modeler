//
//  PbrObject.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import Metal

class PbrObject: RenderObject {
    var materialId: UUID?
    @Published var material: PbrMaterial?

    var uniforms: MTLBuffer?

    init(model: Model) {
        super.init(model: model)
        allocateUniformsBuffer()
    }

    @MainActor
    func setMaterial(materialId: UUID?) {
        // Process if there is a change or if the material is not set
        if materialId != self.material?.id || material == nil {
            // Remove object from current material object list
            if let materialEntry = Renderer.shared.pipelineManager?.pbrPipeline.materials[self.material?.id] {
                let index = materialEntry.material.objects.firstIndex {
                    $0.id == self.id
                }
                
                if let index = index {
                    materialEntry.material.objects.remove(at: index)
                }
            }
            
            let materialEntry = Renderer.shared.pipelineManager?.pbrPipeline.materials[materialId]
            
            materialEntry?.material.objects.append(self)
            material = materialId != nil ? materialEntry?.material : nil
        }
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

    func allocateUniformsBuffer() {
        self.uniforms = Renderer.shared.device!.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
        self.uniforms!.label = "Node Uniforms"
    }
    
    func getUniformsBuffer(index: Int) -> UnsafeMutablePointer<NodeUniforms> {
        UnsafeMutableRawPointer(self.uniforms!.contents())
            .advanced(by: index * alignedNodeUniformsSize)
            .bindMemory(to: NodeUniforms.self, capacity: 1)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(material?.id, forKey: .material)
    }
}
