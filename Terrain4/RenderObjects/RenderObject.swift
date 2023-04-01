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
    var modelMatrixUniformSize = 0
    
    var instanceData: [InstanceData] = []
    
    override init(model: Model?) {
        super.init(model: model)
    }
    
    enum CodingKeys: CodingKey {
        case material
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let materialId = try container.decodeIfPresent(UUID.self, forKey: .material)
        
        try super.init(from: decoder)

        material = Renderer.shared.materialManager.getMaterial(materialId: materialId)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if material != Renderer.shared.materialManager.defaultMaterial {
            try container.encode(material?.id, forKey: .material)
        }
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder) throws {
        throw Errors.notImplemented
    }
    
    func simpleDraw(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        throw Errors.notImplemented
    }
    
    // @MainActor
    func setMaterial(materialId: UUID?) {
        try? Renderer.shared.materialManager.setMaterial(object: self, materialId: materialId)
    }
    
    func setMaterial(material: MaterialWrapper?) {
        try? Renderer.shared.materialManager.setMaterial(object: self, material: material)
    }

    func getUniformsBuffer<T>(index: Int) -> UnsafeMutablePointer<T> {
        UnsafeMutableRawPointer(self.uniforms!.contents())
            .advanced(by: index * uniformsSize)
            .bindMemory(to: T.self, capacity: 1)
    }
    
    func getInstanceData(frame: Int) -> (MTLBuffer?, Int) {
        return (nil, 0)
    }
    
    func allocateModelMatrixUniform(size: Int) {
        modelMatrixUniform = MetalView.shared.device.makeBuffer(length: size, options: [MTLResourceOptions.storageModeShared])!
        modelMatrixUniform!.label = "Model Matrix Uniforms"
    }
    
    func getModelMatrixUniform(index: Int, instances: Int) -> (UnsafeMutablePointer<ModelMatrixUniforms>, Int) {
        let size = instances * MemoryLayout<ModelMatrixUniforms>.stride * 3
        
        if modelMatrixUniformSize < size {
            allocateModelMatrixUniform(size: size)
            modelMatrixUniformSize = size
        }
        
        let offset = index * MemoryLayout<ModelMatrixUniforms>.stride * instances
        
        return (
            UnsafeMutableRawPointer(self.modelMatrixUniform!.contents())
            .advanced(by: offset)
            .bindMemory(to: ModelMatrixUniforms.self, capacity: 1),
            offset
        )
    }
}
