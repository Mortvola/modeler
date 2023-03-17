//
//  RectangleAllocator.swift
//  Terrain4
//
//  Created by Richard Shields on 3/17/23.
//

import Foundation
import Metal
import MetalKit

class RetangleAllocator {
    static func allocate(device: MTLDevice, dimensions: Vec2, segments: VecUInt2) throws -> MTKMesh {
        let meshBufferAllocator = MTKMeshBufferAllocator(device: device)

        let mesh = MDLMesh.newPlane(withDimensions: dimensions, segments: segments, geometryType: .triangles, allocator: meshBufferAllocator)

        mesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

        mesh.vertexDescriptor = SphereAllocator.vertexDescriptor()
        
        return try MTKMesh(mesh: mesh, device: device)
    }
    
    static func vertexDescriptor() -> MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        
        var vertexAttributes = MDLVertexAttribute()
        vertexAttributes.name = MDLVertexAttributePosition
        vertexAttributes.format = .float3
        vertexAttributes.offset = 0
        vertexAttributes.bufferIndex = BufferIndex.meshPositions.rawValue
        vertexDescriptor.attributes[VertexAttribute.position.rawValue] = vertexAttributes
                
        vertexAttributes = MDLVertexAttribute()
        vertexAttributes.name = MDLVertexAttributeTextureCoordinate
        vertexAttributes.format = .float2
        vertexAttributes.offset = MemoryLayout<simd_float3>.stride
        vertexAttributes.bufferIndex = BufferIndex.meshPositions.rawValue
        vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue] = vertexAttributes

        vertexAttributes = MDLVertexAttribute()
        vertexAttributes.name = MDLVertexAttributeNormal
        vertexAttributes.format = .float3
        vertexAttributes.offset = 0
        vertexAttributes.bufferIndex = BufferIndex.normals.rawValue
        vertexDescriptor.attributes[VertexAttribute.normal.rawValue] = vertexAttributes

        vertexAttributes = MDLVertexAttribute()
        vertexAttributes.name = MDLVertexAttributeTangent
        vertexAttributes.format = .float3
        vertexAttributes.offset = MemoryLayout<simd_float3>.stride
        vertexAttributes.bufferIndex = BufferIndex.normals.rawValue
        vertexDescriptor.attributes[VertexAttribute.tangent.rawValue] = vertexAttributes

        var vertexBufferLayout = MDLVertexBufferLayout()
        vertexBufferLayout.stride = MemoryLayout<simd_float3>.stride + MemoryLayout<simd_float2>.stride
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue] = vertexBufferLayout

        vertexBufferLayout = MDLVertexBufferLayout()
        vertexBufferLayout.stride = MemoryLayout<simd_float3>.stride * 2
        vertexDescriptor.layouts[BufferIndex.normals.rawValue] = vertexBufferLayout
        
        return vertexDescriptor
    }
}
