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
    static func allocate(dimensions: Vec2, segments: VecUInt2) throws -> MTKMesh {
        let meshBufferAllocator = MTKMeshBufferAllocator(device: MetalView.shared.device!)

        let mesh = MDLMesh.newPlane(withDimensions: dimensions, segments: segments, geometryType: .triangles, allocator: meshBufferAllocator)

        mesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

        mesh.vertexDescriptor = MeshAllocator.vertexDescriptor()
        
        return try MTKMesh(mesh: mesh, device: MetalView.shared.device!)
    }
}
