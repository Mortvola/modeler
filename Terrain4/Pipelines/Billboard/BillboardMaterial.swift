//
//  BillboardMaterial.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import MetalKit

class BillboardMaterial: Material {
    var filename: String = ""
    var texture: MTLTexture? = nil
    
    var uniforms: MTLBuffer?
    
    init() {
        super.init(name: "Billboard Material")
        allocateUniforms()
    }
    
    @MainActor
    func setTexture(file: String?) async {
        filename = file ?? ""
        await loadTexture()
    }
    
    private func loadTexture() async {
        if !filename.isEmpty {
            texture = try? await TextureManager.shared.addTexture(path: filename)
        }
    }

    override func prepare(renderEncoder: MTLRenderCommandEncoder, frame: Int) {
        renderEncoder.setFragmentTexture(texture, index: 0)
    }
    
    enum CodingKeys: CodingKey {
        case filename
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        filename = try container.decode(String.self, forKey: .filename)
        
        let t = Task {
            await loadTexture()
        }
        
        decoder.addTask(t)
        
        allocateUniforms()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(filename, forKey: .filename)
        
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

    override func updatePipeline(object: RenderObject) {
        Renderer.shared.pipelineManager.billboardPipeline.addMaterial(material: object.material!)
        Renderer.shared.pipelineManager.billboardPipeline.prepareObject(object: object)
    }
}