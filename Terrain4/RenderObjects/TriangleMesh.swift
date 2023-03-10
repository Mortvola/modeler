//
//  TriangleMesh.swift
//  Terrain
//
//  Created by Richard Shields on 2/23/23.
//

import Foundation
import simd
import Metal

class TriangleMesh: RenderObject {
    var vertices: MTLBuffer?
    var normals: MTLBuffer?

    var numVertices: Int = 0
    
    init(
      device: MTLDevice,
      points: [Float],
      normals: [Float],
      indices: [Int],
      model: Model
      // shader: TriangleMeshShader,
    ) {
        super.init(model: model)

        self.createBuffer(device: device, normals: normals, points: points, indices: indices);
    }

    override func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4) {
        var normalMatrix = matrix_float3x3(columns: (
            vector_float3(modelMatrix[0][0], modelMatrix[0][1], modelMatrix[0][2]),
            vector_float3(modelMatrix[1][0], modelMatrix[1][1], modelMatrix[1][2]),
           vector_float3(modelMatrix[2][0], modelMatrix[2][1], modelMatrix[2][2])
        ));
        
        normalMatrix = normalMatrix.inverse.transpose;

        renderEncoder.setVertexBuffer(self.vertices, offset: 0, index: BufferIndex.meshPositions.rawValue)
        renderEncoder.setVertexBuffer(self.normals, offset: 0, index: BufferIndex.normals.rawValue)

        var modelMatrixCopy = modelMatrix
        renderEncoder.setVertexBytes(&modelMatrixCopy, length: MemoryLayout<Matrix4x4>.size, index: BufferIndex.modelMatrix.rawValue)

        renderEncoder.setVertexBytes(&normalMatrix, length: MemoryLayout<matrix_float3x3>.size, index: BufferIndex.normalMatrix.rawValue)

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: self.numVertices)
    }

    func formatData(
        normals: [Float],
        points: [Float],
        indices: [Int]
    ) -> ([simd_float1], [simd_float1]) {
        // Buffer for the vertex data (position, texture, normal, tangent)
        var buffer: [simd_float1] = [];
        var lighting: [simd_float1] = [];

//      const edge1 = Vec3.create();
//      const edge2 = Vec3.create();
//      const deltaUV1 = Vec2.create();
//      const deltaUV2 = Vec2.create();

        let max = indices.count
        for i in stride(from: 0, to: max, by: 3) {
          var pointCoords: [simd_float3] = [];
          var textureCoords: [simd_float2] = [];
          var vertexNormals: [simd_float3] = [];

          for j in stride(from: 0, to: 3, by: 1) {
              let index = indices[i + j];

              pointCoords.append(simd_make_float3(
                points[index * 5 + 0],
                points[index * 5 + 2],  // Swap Y and Z for now
                points[index * 5 + 1]
              ))
    
              textureCoords.append(simd_make_float2(
                points[index * 5 + 3],
                points[index * 5 + 4]
              ))
    
              vertexNormals.append(simd_make_float3(
                normals[index * 3 + 0],
                normals[index * 3 + 2],  // Swap Y and Z for now
                normals[index * 3 + 1]
              ))
          }

          for j in stride(from: 0, to: 3, by: 1) {
              let edge1 = pointCoords[j + 0].subtract(pointCoords[(j + 1) % 3])
              let edge2 = pointCoords[j + 0].subtract(pointCoords[(j + 2) % 3])
              let deltaUV1 = textureCoords[j + 0].subtract(textureCoords[(j + 1) % 3])
              let deltaUV2 = textureCoords[j + 0].subtract(textureCoords[(j + 2) % 3])

              // inverse of the matrix determinant
              let f = 1.0 / (deltaUV1[0] * deltaUV2[1] - deltaUV2[0] * deltaUV1[1]);

              let tangent = Vec3(
                f * (deltaUV2[1] * edge1[0] - deltaUV1[1] * edge2[0]),
                f * (deltaUV2[1] * edge1[1] - deltaUV1[1] * edge2[1]),
                f * (deltaUV2[1] * edge1[2] - deltaUV1[1] * edge2[2])
              ).normalize()

//               let bitangent = Vec3(
//                 f * (deltaUV1[0] * edge2[0] - deltaUV2[0] * edge1[0]),
//                 f * (deltaUV1[0] * edge2[1] - deltaUV2[0] * edge1[1]),
//                 f * (deltaUV1[0] * edge2[2] - deltaUV2[0] * edge1[2])
//               )

              buffer.append(pointCoords[j].x);
              buffer.append(pointCoords[j].y);
              buffer.append(pointCoords[j].z);
              buffer.append(0);

              buffer.append(textureCoords[j].x);
              buffer.append(textureCoords[j].y);

              lighting.append(vertexNormals[j].x);
              lighting.append(vertexNormals[j].y);
              lighting.append(vertexNormals[j].z);
              lighting.append(0);

              lighting.append(tangent[0]);
              lighting.append(tangent[1]);
              lighting.append(tangent[2]);
              lighting.append(0);

          // buffer.push(bitangent[0]);
          // buffer.push(bitangent[1]);
          // buffer.push(bitangent[2]);

          self.numVertices += 1;
        }
      }

      return (buffer, lighting);
    }

    func createBuffer(
      device: MTLDevice,
      normals: [Float],
      points: [Float],
      indices: [Int]
      // shader: TriangleMeshShader,
    ) {
        let (points, normals) = self.formatData(normals: normals, points: points, indices: indices)
        
        var dataSize = points.count * MemoryLayout.size(ofValue: points[0]) * 6
        self.vertices = device.makeBuffer(bytes: points, length: dataSize, options: [])!

        dataSize = normals.count * MemoryLayout.size(ofValue: normals[0]) * 8
        self.normals = device.makeBuffer(bytes: normals, length: dataSize, options: [])!
    }
}
