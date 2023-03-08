//
//  Sphere.swift
//  Terrain
//
//  Created by Richard Shields on 3/5/23.
//

import Foundation
import Metal
import MetalKit

class Sphere: Model {
    var objects: [RenderObject] = []
    
    init(device: MTLDevice, view: MTKView, diameter: Float) async throws {
        super.init()
        
        let material = try await MaterialManager.shared.addMaterial(device: device, view: view, name: .terrain)

        let meshBufferAllocator = MTKMeshBufferAllocator(device: device)

        let mesh = MDLMesh.newEllipsoid(withRadii: vec3(diameter, diameter, diameter), radialSegments: 32, verticalSegments: 32, geometryType: .triangles, inwardNormals: false, hemisphere: false, allocator: meshBufferAllocator)

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
        
        let sphere = try MTKMesh(mesh: mesh, device: device)

        let object = Mesh(mesh: sphere, model: self)
        
        material.objects.append(object)
        self.objects.append(object)
    }
}
