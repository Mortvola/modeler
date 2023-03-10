//
//  Mesh.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import Foundation
import Metal
import MetalKit

class Mesh: RenderObject {
    let mesh: MTKMesh
    
    init(mesh: MTKMesh, model: Model) {
        self.mesh = mesh

        super.init(model: model)
    }
    
    override func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4) throws {
        // Pass the normal matrix (derived from the model matrix) to the vertex shader
        var normalMatrix = matrix_float3x3(columns: (
            vector_float3(modelMatrix[0][0], modelMatrix[0][1], modelMatrix[0][2]),
            vector_float3(modelMatrix[1][0], modelMatrix[1][1], modelMatrix[1][2]),
           vector_float3(modelMatrix[2][0], modelMatrix[2][1], modelMatrix[2][2])
        ));
        
        normalMatrix = normalMatrix.inverse.transpose;

        renderEncoder.setVertexBytes(&normalMatrix, length: MemoryLayout<matrix_float3x3>.size, index: BufferIndex.normalMatrix.rawValue)

        // Pass the model matrix to the vertex shader.
        var modelMatrixCopy = modelMatrix
        renderEncoder.setVertexBytes(&modelMatrixCopy, length: MemoryLayout<Matrix4x4>.size, index: BufferIndex.modelMatrix.rawValue)

        // Pass the vertex and index information ot the vertex shader
        for (i, buffer) in self.mesh.vertexBuffers.enumerated() {
            renderEncoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: i)
        }
        
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        }
    }
}
