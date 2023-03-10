//
//  SphereAllocator.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import Foundation
import Metal
import MetalKit

class SphereAllocator {
    static func allocate(device: MTLDevice, diameter: Float) throws -> MTKMesh {
        let meshBufferAllocator = MTKMeshBufferAllocator(device: device)

        let mesh = MDLMesh.newEllipsoid(withRadii: Vec3(diameter, diameter, diameter), radialSegments: 32, verticalSegments: 32, geometryType: .triangles, inwardNormals: false, hemisphere: false, allocator: meshBufferAllocator)

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

        mesh.addOrthTanBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

        mesh.vertexDescriptor = vertexDescriptor
        
        return try MTKMesh(mesh: mesh, device: device)
    }
}
