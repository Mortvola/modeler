//
//  TriangleMesh.swift
//  Terrain
//
//  Created by Richard Shields on 2/23/23.
//

import Foundation
import simd
import Metal

class TriangleMesh {
    
    var vertices: MTLBuffer?
    
    var numVertices: Int = 0
    
    init(
      device: MTLDevice,
      points: [Double],
      normals: [Double],
      indices: [Int]
      // shader: TriangleMeshShader,
    ) {
        self.createBuffer(device: device, normals: normals, points: points, indices: indices);
    }

    func draw(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setVertexBuffer(self.vertices, offset: 0, index: 0)

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: numVertices,
                                     instanceCount: self.numVertices)
    }

    func formatData(
      normals: [Double],
      points: [Double],
      indices: [Int]
    ) -> [Double] {
      // Buffer for the vertex data (position, texture, normal, tangent)
      var buffer: [Double] = [];

//      const edge1 = vec3.create();
//      const edge2 = vec3.create();
//      const deltaUV1 = vec2.create();
//      const deltaUV2 = vec2.create();

        for i in stride(from: 0, to: indices.count, by: 3) {
          var pointCoords: [simd_double3] = [];
          var textureCoords: [simd_double2] = [];
          var vertexNormals: [simd_double3] = [];

          for j in stride(from: 0, to: 3, by: 1) {
              let index = indices[i + j];

              pointCoords.append(simd_make_double3(
                points[index * 5 + 0],
                points[index * 5 + 1],
                points[index * 5 + 2]
              ))
    
              textureCoords.append(simd_make_double2(
                points[index * 5 + 3],
                points[index * 5 + 4]
              ))
    
              vertexNormals.append(simd_make_double3(
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
              buffer.append(pointCoords[j].y);
              buffer.append(pointCoords[j].z);

              buffer.append(textureCoords[j].x);
              buffer.append(textureCoords[j].y);

              buffer.append(vertexNormals[j].x);
              buffer.append(vertexNormals[j].y);
              buffer.append(vertexNormals[j].z);

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
      normals: [Double],
      points: [Double],
      indices: [Int]
      // shader: TriangleMeshShader,
    ) {
        let data = self.formatData(normals: normals, points: points, indices: indices)

        let dataSize = data.count * MemoryLayout.size(ofValue: data[0])
        self.vertices = device.makeBuffer(bytes: data, length: dataSize, options: [])!

//        if (buf = ) {
//            return
//        }

//      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, buf);
//      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(data), this.gl.STATIC_DRAW);
//      this.gl.enableVertexAttribArray(shader.vertexPosition);
//      this.gl.vertexAttribPointer(
//        shader.vertexPosition,
//        3, // Number of components
//        this.gl.FLOAT,
//        false, // normalize
//        vertexStride * floatSize, // stride
//        0, // offset
//      );
//
//      this.gl.enableVertexAttribArray(shader.attribLocations.texCoord);
//      this.gl.vertexAttribPointer(
//        shader.attribLocations.texCoord,
//        2, // Number of components
//        this.gl.FLOAT,
//        false, // normalize
//        vertexStride * floatSize, // stride
//        3 * floatSize, // offset
//      );
//
//      this.gl.enableVertexAttribArray(shader.attribLocations.vertexNormal);
//      this.gl.vertexAttribPointer(
//        shader.attribLocations.vertexNormal,
//        3, // Number of components
//        this.gl.FLOAT,
//        false, // normalize
//        vertexStride * floatSize, // stride
//        5 * floatSize, // offset
//      );
//
//      this.gl.enableVertexAttribArray(shader.attribLocations.tangent);
//      this.gl.vertexAttribPointer(
//        shader.attribLocations.tangent,
//        3, // Number of components
//        this.gl.FLOAT,
//        false, // normalize
//        vertexStride * floatSize, // stride
//        8 * floatSize, // offset
//      );
    }}
