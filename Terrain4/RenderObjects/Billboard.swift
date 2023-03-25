//
//  Billboard.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import Metal

class Billboard: RenderObject {
    var color = Vec4(1.0, 1.0, 1.0, 1.0)
    var size = Vec2(1.0, 1.0)
    
    var vertex: MTLBuffer?
    var vertexCount: Int = 0
    var uniforms: MTLBuffer?
    
    let alignedNodeUniformsSize = MemoryLayout<BillboardUniforms>.size // (MemoryLayout<NodeUniforms>.size + 0xFF) & -0x100

    init(model: Model) {
        super.init(model: model)
        allocateVertexBuffer()
        allocateUniformsBuffer()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        allocateVertexBuffer()
        allocateUniformsBuffer()
    }

    func allocateVertexBuffer() {
        var v = [Vec2(-1, 1), Vec2(1, 1), Vec2(-1, -1), Vec2(-1, -1), Vec2(1, 1), Vec2(1, -1)]
        let length = MemoryLayout<Vec2>.size * v.count
        
        self.vertex = Renderer.shared.device!.makeBuffer(bytes: &v, length: length, options: [])!
        self.vertexCount = v.count
    }
    
    func allocateUniformsBuffer() {
        self.uniforms = Renderer.shared.device!.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
        self.uniforms!.label = "Billboard Uniforms"
    }

    func getUniformsBuffer(index: Int) -> UnsafeMutablePointer<BillboardUniforms> {
        UnsafeMutableRawPointer(self.uniforms!.contents())
            .advanced(by: index * alignedNodeUniformsSize)
            .bindMemory(to: BillboardUniforms.self, capacity: 1)
    }

//    override func setMaterial(materialEntry: MaterialEntry) {
//        switch materialEntry {
//        case .pbrMaterial:
////            m.objects.append(self)
////            self.material = m
//            break;
//        case .billboardMaterial:
////            m.objects.append(self)
////            self.material = m
//            break //m.objects.append(self)
//        case .pointMaterial:
//            break //m.objects.append(self)
//        case .simpleMaterial:
//            break
//        }
//    }

//    @MainActor
//    func setMaterial(materialId: UUID?) {
//        let materialEntry = Renderer.shared.pipelineManager?.billboardPipeline.materials[materialId]
//
//        materialEntry?.material.objects.append(self)
//        material = materialId != nil ? materialEntry?.material : nil
//    }

    override func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        try self.simpleDraw(renderEncoder: renderEncoder, modelMatrix: modelMatrix, frame: frame)
    }
    
    override func simpleDraw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        let u = self.getUniformsBuffer(index: frame)
        u[0].modelMatrix = modelMatrix
        u[0].color = color
        u[0].scale = size

        renderEncoder.setVertexBuffer(self.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)

        renderEncoder.setVertexBuffer(vertex, offset: 0, index: BufferIndex.meshPositions.rawValue)

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
    }
    
    override func typeString() -> String {
        "Billboard"
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}
