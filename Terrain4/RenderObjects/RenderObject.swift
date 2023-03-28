//
//  RenderObject.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import Metal

let alignedNodeUniformsSize = MemoryLayout<NodeUniforms>.size // (MemoryLayout<NodeUniforms>.size + 0xFF) & -0x100

struct InstanceData {
    let transformation: Matrix4x4
}

class RenderObject: Object {
    // lights that may affect this object.
    var lights: [Light] = []
    @Published var material: MaterialWrapper?
    var uniforms: MTLBuffer?
    var uniformsSize = 0
    var modelMatrixUniform: MTLBuffer?
    var instanceData: [InstanceData] = []
    
    override init(model: Model?) {
        super.init(model: model)
        allocateModelMatrixUniform()
    }
    
    enum CodingKeys: CodingKey {
        case material
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let materialId = try container.decodeIfPresent(UUID.self, forKey: .material)
        
        try super.init(from: decoder)

        material = Renderer.shared.materialManager.getMaterial(materialId: materialId)
        
        allocateModelMatrixUniform()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if material != Renderer.shared.materialManager.defaultMaterial {
            try container.encode(material?.id, forKey: .material)
        }
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        throw Errors.notImplemented
    }
    
    func simpleDraw(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        throw Errors.notImplemented
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder) throws {
        throw Errors.notImplemented
    }
    
    // @MainActor
    func setMaterial(materialId: UUID?) {
        Renderer.shared.materialManager.setMaterial(object: self, materialId: materialId)
    }
    
    func setMaterial(material: MaterialWrapper?) {
        Renderer.shared.materialManager.setMaterial(object: self, material: material)
    }

    func getUniformsBuffer<T>(index: Int) -> UnsafeMutablePointer<T> {
        UnsafeMutableRawPointer(self.uniforms!.contents())
            .advanced(by: index * uniformsSize)
            .bindMemory(to: T.self, capacity: 1)
    }
    
    func allocateModelMatrixUniform() {
        let numInstances = 3
        modelMatrixUniform = MetalView.shared.device.makeBuffer(length: 3 * MemoryLayout<Matrix4x4>.stride * numInstances, options: [MTLResourceOptions.storageModeShared])!
        modelMatrixUniform!.label = "Model Matrix Uniforms"
    }
    
    func getModelMatrixUniform(index: Int, instances: Int) -> UnsafeMutablePointer<Matrix4x4> {
        let numInstances = 3
        return UnsafeMutableRawPointer(self.modelMatrixUniform!.contents())
            .advanced(by: index * MemoryLayout<Matrix4x4>.stride * numInstances)
            .bindMemory(to: Matrix4x4.self, capacity: 1)
    }
}
