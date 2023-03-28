//
//  ConeAllocator.swift
//  Terrain4
//
//  Created by Richard Shields on 3/22/23.
//

import Foundation
import Metal
import MetalKit

class ConeAllocator {
    static func allocate(options: ConeOptions) throws -> MTKMesh {
        let meshBufferAllocator = MTKMeshBufferAllocator(device: MetalView.shared.device)

        let mesh = MDLMesh.newEllipticalCone(withHeight: options.height, radii: options.radii, radialSegments: options.radialSegments, verticalSegments: options.verticalSegments, geometryType: .triangles, inwardNormals: false, allocator: meshBufferAllocator)

        mesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

        mesh.vertexDescriptor = MeshAllocator.vertexDescriptor()
        
        return try MTKMesh(mesh: mesh, device: MetalView.shared.device)
    }
}
