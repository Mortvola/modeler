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
    
    init(device: MTLDevice, points: [Float], model: Model) {
        // Reformat data
        var newPoints: [simd_float1] = []
        
        for i in stride(from: 0, to: points.count, by: 3) {
            newPoints.append(points[i + 0])
            newPoints.append(points[i + 2])
            newPoints.append(points[i + 1])
            newPoints.append(0)
        }
                                    
        let dataSize = newPoints.count * MemoryLayout.size(ofValue: newPoints[0])
        self.vertices = device.makeBuffer(bytes: newPoints, length: dataSize, options: [])!
        self.numVertices = newPoints.count * MemoryLayout.size(ofValue: newPoints[0]) / MemoryLayout<simd_float3>.stride
        
        super.init(model: model)
    }

    override func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4) {
        renderEncoder.setVertexBuffer(self.vertices, offset: 0, index: BufferIndex.meshPositions.rawValue)

        var modelMatrixCopy = modelMatrix
        renderEncoder.setVertexBytes(&modelMatrixCopy, length: MemoryLayout<Matrix4x4>.size, index: BufferIndex.modelMatrix.rawValue)
        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: self.numVertices)
    }
}
