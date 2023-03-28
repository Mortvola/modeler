//
//  Line.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import Metal

class Line: RenderObject {
    let vertices: MTLBuffer
    
    let numVertices: Int
    
    init(points: [Float], model: Model) {
        // Reformat data
        var newPoints: [simd_float1] = []
        
        for i in stride(from: 0, to: points.count, by: 3) {
            newPoints.append(points[i + 0])
            newPoints.append(points[i + 2])
            newPoints.append(points[i + 1])
            newPoints.append(0)
        }
                                    
        let dataSize = newPoints.count * MemoryLayout.size(ofValue: newPoints[0])
        self.vertices = MetalView.shared.device!.makeBuffer(bytes: newPoints, length: dataSize, options: [])!
        self.numVertices = newPoints.count * MemoryLayout.size(ofValue: newPoints[0]) / MemoryLayout<simd_float3>.stride
        
        super.init(model: model)
    }

    public required init(from decoder: Decoder) throws {
        let points: [Float] = []
        
        // Reformat data
        var newPoints: [simd_float1] = []
        
        for i in stride(from: 0, to: points.count, by: 3) {
            newPoints.append(points[i + 0])
            newPoints.append(points[i + 2])
            newPoints.append(points[i + 1])
            newPoints.append(0)
        }
                                    
        let dataSize = newPoints.count * MemoryLayout.size(ofValue: newPoints[0])
        self.vertices = MetalView.shared.device!.makeBuffer(bytes: newPoints, length: dataSize, options: [])!
        self.numVertices = newPoints.count * MemoryLayout.size(ofValue: newPoints[0]) / MemoryLayout<simd_float3>.stride

        try super.init(from: decoder)
    }

//    override func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, pbrProperties: PbrProperties?, frame: Int) {
//        renderEncoder.setVertexBuffer(self.vertices, offset: 0, index: BufferIndex.meshPositions.rawValue)
//
//        let u = getUniformsBuffer(index: frame)
//        u[0].modelMatrix = modelMatrix
//
//        renderEncoder.setVertexBuffer(self.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)
//
//        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: self.numVertices)
//    }
}
