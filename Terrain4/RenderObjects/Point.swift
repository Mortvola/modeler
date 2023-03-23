//
//  Point.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import Metal

class Point: RenderObject {
    var materialId: UUID?
    @Published var material: PointMaterial?
    var color = Vec4(1.0, 1.0, 1.0, 1.0)
    var size = Float(64)
    
    var vertex: MTLBuffer?
    var uniforms: MTLBuffer?
    
    let alignedNodeUniformsSize = MemoryLayout<PointUniforms>.size // (MemoryLayout<NodeUniforms>.size + 0xFF) & -0x100

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
        var v = Vec3(0, 0, 0)
        let length = MemoryLayout<Vec3>.size
        
        self.vertex = Renderer.shared.device!.makeBuffer(bytes: &v, length: length, options: [])!
    }
    
    func allocateUniformsBuffer() {
        self.uniforms = Renderer.shared.device!.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
        self.uniforms!.label = "Point Uniforms"
    }

    func getUniformsBuffer(index: Int) -> UnsafeMutablePointer<PointUniforms> {
        UnsafeMutableRawPointer(self.uniforms!.contents())
            .advanced(by: index * alignedNodeUniformsSize)
            .bindMemory(to: PointUniforms.self, capacity: 1)
    }
    
    @MainActor
    func setMaterial(materialId: UUID?) {
        let materialEntry = Renderer.shared.pipelineManager?.pointPipeline.materials[materialId]
        
        materialEntry?.material.objects.append(self)
        material = materialId != nil ? materialEntry?.material : nil
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        try self.simpleDraw(renderEncoder: renderEncoder, modelMatrix: modelMatrix, frame: frame)
    }
    
    override func simpleDraw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        let u = self.getUniformsBuffer(index: frame)
        u[0].modelMatrix = modelMatrix
        u[0].color = color
        u[0].size = size

        renderEncoder.setVertexBuffer(self.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)

        renderEncoder.setVertexBuffer(vertex, offset: 0, index: BufferIndex.meshPositions.rawValue)

        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 1)
    }
}
