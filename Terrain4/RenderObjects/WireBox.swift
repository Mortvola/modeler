//
//  Fustrum.swift
//  Terrain4
//
//  Created by Richard Shields on 3/20/23.
//

import Foundation
import Metal

class WireBox: RenderObject {
    let vertices: MTLBuffer
    
    let numVertices: Int
    
    let color: Vec4
    
    init(device: MTLDevice, points: [Vec4], color: Vec4) {
        self.vertices = device.makeBuffer(length: 24 * MemoryLayout<Vec4>.size, options: [MTLResourceOptions.storageModeShared])!
        self.vertices.label = "WireBox Vertices"
        self.numVertices = 24
        
        self.color = color
        
        super.init(model: nil)
        
        updateVertices(points: points)
    }
    
    func updateVertices(points: [Vec4]) {
        let v: UnsafeMutablePointer<Vec4> = UnsafeMutableRawPointer(self.vertices.contents()).bindMemory(to: Vec4.self, capacity: 24)

        for i in [0, 4] {
            v[2 * i + 0] = points[i + 0]
            v[2 * i + 1] = points[i + 1]
            
            v[2 * i + 2] = points[i + 1]
            v[2 * i + 3] = points[i + 3]
            
            v[2 * i + 4] = points[i + 3]
            v[2 * i + 5] = points[i + 2]
            
            v[2 * i + 6] = points[i + 2]
            v[2 * i + 7] = points[i + 0]
        }

        for i in 0...3 {
            v[i * 2 + 16] = points[i]
            v[i * 2 + 17] = points[i + 4]
        }
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
        
        self.color = Vec4(1, 1, 1, 1)
        
        try super.init(from: decoder)
    }

//    override func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, pbrProperties: PbrProperties?, frame: Int) {
//        renderEncoder.setVertexBuffer(self.vertices, offset: 0, index: BufferIndex.meshPositions.rawValue)
//
//        let u = getUniformsBuffer(index: frame)
//        u[0].color = color
//        u[0].modelMatrix = modelMatrix
//        u[0].normalMatrix = Matrix3x3.identity()
//        
//        renderEncoder.setVertexBuffer(self.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)
//        
//        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: self.numVertices)
//    }
}
