//
//  GraphMaterial.swift
//  Terrain4
//
//  Created by Richard Shields on 3/24/23.
//

import Foundation
import Metal
import MetalKit


class GraphMaterial: Material {
    @Published var layers: [GraphNodeWrapper] = []
    
    var uniforms: MTLBuffer?

    init() {
        super.init(name: "Graph Material")
        allocateUniforms()
    }
    
    override func pipelineType() -> PipelineType {
        .graphPipeline
    }

    func deleteLayer(id: UUID) {
        let index = layers.firstIndex {
            $0.id == id
        }
        
        if let index = index {
            layers.remove(at: index)
        }
    }
    
    override func prepare(renderEncoder: MTLRenderCommandEncoder, frame: Int) {
        let u: UnsafeMutablePointer<GraphUniforms> = getUniformsBuffer(index: frame)

        u[0].argOffset.0 = 0
        u[0].argOffset.1 = 4
        u[0].argOffset.2 = 5
        
        u[0].arg.0 = Float(1.0)
        u[0].arg.1 = Float(1.0)
        u[0].arg.2 = Float(1.0)
        u[0].arg.3 = Float(1.0)
        
        u[0].arg.4 = Float(0.2)
        u[0].arg.5 = Float(0.0)
        
        renderEncoder.setFragmentBuffer(uniforms, offset: frame * MemoryLayout<GraphUniforms>.stride, index: BufferIndex.materialUniforms.rawValue)

        for layer in layers {
            switch layer {
            case .texture(let l):
                renderEncoder.setFragmentTexture(l.texture, index: 0)
            default:
                break
            }
        }
    }
    
    enum CodingKeys: CodingKey {
        case layers
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        layers = try container.decode([GraphNodeWrapper].self, forKey: .layers)
        
        allocateUniforms()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(layers, forKey: .layers)
        
        try super.encode(to: encoder)
    }
    
    func allocateUniforms() {
        uniforms = MetalView.shared.device.makeBuffer(length: 3 * MemoryLayout<GraphUniforms>.stride, options: [MTLResourceOptions.storageModeShared])!
        uniforms!.label = "Material Uniforms"
    }
    
    func getUniformsBuffer(index: Int) -> UnsafeMutablePointer<GraphUniforms> {
        UnsafeMutableRawPointer(self.uniforms!.contents())
            .advanced(by: index * MemoryLayout<GraphUniforms>.stride)
            .bindMemory(to: GraphUniforms.self, capacity: 1)
    }
}
