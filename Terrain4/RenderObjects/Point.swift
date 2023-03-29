//
//  Point.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import Metal

class Point: RenderObject {
    var color = Vec4(1.0, 1.0, 1.0, 1.0)
    var size = Float(64)
    
    var vertex: MTLBuffer?
//    var uniforms: MTLBuffer?
    
    let alignedNodeUniformsSize = MemoryLayout<PointUniforms>.size // (MemoryLayout<NodeUniforms>.size + 0xFF) & -0x100

    init(model: Model) {
        super.init(model: model)
        allocateVertexBuffer()
//        allocateUniformsBuffer()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        allocateVertexBuffer()
//        allocateUniformsBuffer()
    }

    func allocateVertexBuffer() {
        var v = Vec3(0, 0, 0)
        let length = MemoryLayout<Vec3>.size
        
        self.vertex = MetalView.shared.device.makeBuffer(bytes: &v, length: length, options: [])!
    }
    
//    func allocateUniformsBuffer() {
//        self.uniforms = Renderer.shared.device.makeBuffer(length: 3 * alignedNodeUniformsSize, options: [MTLResourceOptions.storageModeShared])!
//        self.uniforms!.label = "Point Uniforms"
//    }

//    func getUniformsBuffer(index: Int) -> UnsafeMutablePointer<PointUniforms> {
//        UnsafeMutableRawPointer(self.uniforms!.contents())
//            .advanced(by: index * alignedNodeUniformsSize)
//            .bindMemory(to: PointUniforms.self, capacity: 1)
//    }
    
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
//        case .graphMaterial:
//            break
//        }
//    }

//    @MainActor
//    func setMaterial(materialId: UUID?) {
//        let materialEntry = Renderer.shared.pipelineManager.pointPipeline.materials[materialId]
//
//        materialEntry?.material.objects.append(self)
//        material = materialId != nil ? materialEntry?.material : nil
//    }

    override func draw(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        try self.simpleDraw(renderEncoder: renderEncoder, frame: frame)
    }
    
    override func simpleDraw(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        let u: UnsafeMutablePointer<PointUniforms> = self.getUniformsBuffer(index: frame)
        u[0].modelMatrix = instanceData[0].transformation
        u[0].color = color
        u[0].size = size

        renderEncoder.setVertexBuffer(self.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)

        renderEncoder.setVertexBuffer(vertex, offset: 0, index: BufferIndex.meshPositions.rawValue)

        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 1)
    }
}
