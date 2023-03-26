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
    @Published var material: MaterialWrapper?
    var uniforms: MTLBuffer?
    var uniformsSize = 0
    var modelMatrixUniform: MTLBuffer?
    
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

        setMaterial(materialId: materialId)
        
        allocateModelMatrixUniform()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if material != Renderer.shared.materialManager.defaultMaterial {
            try container.encode(material?.id, forKey: .material)
        }
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        throw Errors.notImplemented
    }
    
    func simpleDraw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        let matrix: UnsafeMutablePointer<Matrix4x4> = self.getModelMatrixUniform(index: frame)
        matrix[0] = modelMatrix
        
        renderEncoder.setVertexBuffer(self.modelMatrixUniform, offset: 0, index: BufferIndex.modelMatrix.rawValue)

        try self.draw(renderEncoder: renderEncoder)
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
        modelMatrixUniform = MetalView.shared.device!.makeBuffer(length: 3 * MemoryLayout<Matrix4x4>.stride, options: [MTLResourceOptions.storageModeShared])!
        modelMatrixUniform!.label = "Model Matrix Uniforms"
    }
    
    func getModelMatrixUniform(index: Int) -> UnsafeMutablePointer<Matrix4x4> {
        UnsafeMutableRawPointer(self.modelMatrixUniform!.contents())
            .advanced(by: index * MemoryLayout<Matrix4x4>.stride)
            .bindMemory(to: Matrix4x4.self, capacity: 1)
    }
}
