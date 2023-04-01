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
    var color = Vec4(1, 1, 1, 1)
    
    var uniforms: MTLBuffer?
    
    init() {
        super.init(name: "Billboard Material")
        allocateUniforms()
    }
    
    override func pipelineType() -> PipelineType {
        .billboardPipeline
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
        let u = getUniformsBuffer(index: frame)

        u[0].color = color
        
        renderEncoder.setFragmentBuffer(uniforms, offset: frame * MemoryLayout<BillboardUniforms>.stride, index: BufferIndex.materialUniforms.rawValue)

        renderEncoder.setFragmentTexture(texture, index: 0)
    }
    
    enum CodingKeys: CodingKey {
        case filename
        case color
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        filename = try container.decode(String.self, forKey: .filename)
        color = try container.decodeIfPresent(Vec4.self, forKey: .color) ?? Vec4(1, 1, 1, 1)
        
        let t = Task {
            await loadTexture()
        }
        
        decoder.addTask(t)
        
        allocateUniforms()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(filename, forKey: .filename)
        try container.encode(color, forKey: .color)
        
        try super.encode(to: encoder)
    }
    
    func allocateUniforms() {
        uniforms = MetalView.shared.device.makeBuffer(length: 3 * MemoryLayout<BillboardUniforms>.stride, options: [MTLResourceOptions.storageModeShared])!
        uniforms!.label = "Material Uniforms"
    }
    
    func getUniformsBuffer(index: Int) -> UnsafeMutablePointer<BillboardUniforms> {
        UnsafeMutableRawPointer(self.uniforms!.contents())
            .advanced(by: index * MemoryLayout<BillboardUniforms>.stride)
            .bindMemory(to: BillboardUniforms.self, capacity: 1)
    }
}
