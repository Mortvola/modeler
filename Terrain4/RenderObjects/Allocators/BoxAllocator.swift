//
//  BoxAllocator.swift
//  Terrain4
//
//  Created by Richard Shields on 3/22/23.
//

import Foundation
import Metal
import MetalKit

class BoxAllocator {
    static func allocate(dimensions: Vec3, segments: VecUInt3) throws -> MTKMesh {
        let meshBufferAllocator = MTKMeshBufferAllocator(device: MetalView.shared.device!)

        let mesh = MDLMesh.newBox(withDimensions: dimensions, segments: segments, geometryType: .triangles, inwardNormals: false, allocator: meshBufferAllocator)

        mesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

        mesh.vertexDescriptor = MeshAllocator.vertexDescriptor()
        
        return try MTKMesh(mesh: mesh, device: MetalView.shared.device!)
    }
}
