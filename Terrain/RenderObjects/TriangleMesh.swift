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
    
    var numVertices: Int = 0
    
    let model: TerrainTile
    
    init(
      device: MTLDevice,
      points: [Float],
      normals: [Float],
      indices: [Int],
      model: TerrainTile
      // shader: TriangleMeshShader,
    ) {
        self.model = model
        self.createBuffer(device: device, normals: normals, points: points, indices: indices);
    }

    func modelMatrix() -> matrix_float4x4 {
        self.model.modelMatrix
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: matrix_float4x4) {
        renderEncoder.setVertexBuffer(self.vertices, offset: 0, index: BufferIndex.meshPositions.rawValue)

        var modelMatrixCopy = modelMatrix
        renderEncoder.setVertexBytes(&modelMatrixCopy, length: MemoryLayout<matrix_float4x4>.size, index: BufferIndex.modelMatrix.rawValue)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: self.numVertices)
    }

    func formatData(
        normals: [Float],
        points: [Float],
        indices: [Int]
    ) -> [simd_float1] {
        // Buffer for the vertex data (position, texture, normal, tangent)
        var buffer: [simd_float1] = [];

//      const edge1 = vec3.create();
//      const edge2 = vec3.create();
//      const deltaUV1 = vec2.create();
//      const deltaUV2 = vec2.create();

        let max = indices.count
        for i in stride(from: 0, to: max, by: 3) {
          var pointCoords: [simd_float3] = [];
          var textureCoords: [simd_float2] = [];
          var vertexNormals: [simd_float3] = [];

          for j in stride(from: 0, to: 3, by: 1) {
              let index = indices[i + j];

              pointCoords.append(simd_make_float3(
                points[index * 5 + 0],
                points[index * 5 + 1],
                points[index * 5 + 2]
              ))
    
              textureCoords.append(simd_make_float2(
                points[index * 5 + 3],
                points[index * 5 + 4]
              ))
    
              vertexNormals.append(simd_make_float3(
                normals[index * 3 + 0],
                normals[index * 3 + 1],
                normals[index * 3 + 2]
              ))
          }

          for j in stride(from: 0, to: 3, by: 1) {
//          vec3.subtract(edge1, pointCoords[j + 0], pointCoords[(j + 1) % 3]);
//          vec3.subtract(edge2, pointCoords[j + 0], pointCoords[(j + 2) % 3]);
//          vec2.subtract(deltaUV1, textureCoords[j + 0], textureCoords[(j + 1) % 3]);
//          vec2.subtract(deltaUV2, textureCoords[j + 0], textureCoords[(j + 2) % 3]);
//
//          // inverse of the matrix determinant
//          const f = 1.0 / (deltaUV1[0] * deltaUV2[1] - deltaUV2[0] * deltaUV1[1]);
//
//          const tangent = vec3.fromValues(
//            f * (deltaUV2[1] * edge1[0] - deltaUV1[1] * edge2[0]),
//            f * (deltaUV2[1] * edge1[1] - deltaUV1[1] * edge2[1]),
//            f * (deltaUV2[1] * edge1[2] - deltaUV1[1] * edge2[2]),
//          )

          // const bitangent = vec3.fromValues(
          //   f * (deltaUV1[0] * edge2[0] - deltaUV2[0] * edge1[0]),
          //   f * (deltaUV1[0] * edge2[1] - deltaUV2[0] * edge1[1]),
          //   f * (deltaUV1[0] * edge2[2] - deltaUV2[0] * edge1[2]),
          // )

              buffer.append(pointCoords[j].x);
              buffer.append(pointCoords[j].z);
              buffer.append(pointCoords[j].y);
              buffer.append(0);

              buffer.append(textureCoords[j].x);
              buffer.append(textureCoords[j].y);

              buffer.append(vertexNormals[j].x);
              buffer.append(vertexNormals[j].z);
              buffer.append(vertexNormals[j].y);
              buffer.append(0);

//          buffer.append(tangent[0]);
//          buffer.append(tangent[1]);
//          buffer.append(tangent[2]);

          // buffer.push(bitangent[0]);
          // buffer.push(bitangent[1]);
          // buffer.push(bitangent[2]);

          self.numVertices += 1;
        }
      }

      return buffer;
    }

    func createBuffer(
      device: MTLDevice,
      normals: [Float],
      points: [Float],
      indices: [Int]
      // shader: TriangleMeshShader,
    ) {
        let data = self.formatData(normals: normals, points: points, indices: indices)
        
        let dataSize = data.count * MemoryLayout.size(ofValue: data[0]) * 10
        self.vertices = device.makeBuffer(bytes: data, length: dataSize, options: [])!
    }
}
