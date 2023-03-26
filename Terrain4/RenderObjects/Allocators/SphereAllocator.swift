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
    static func allocate(diameter: Float, radialSegments: Int, verticalSegments: Int, hemisphere: Bool) throws -> MTKMesh {
        let meshBufferAllocator = MTKMeshBufferAllocator(device: MetalView.shared.device!)

        let mesh = MDLMesh.newEllipsoid(withRadii: Vec3(diameter, diameter, diameter), radialSegments: radialSegments, verticalSegments: verticalSegments, geometryType: .triangles, inwardNormals: false, hemisphere: hemisphere, allocator: meshBufferAllocator)

        mesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

        mesh.vertexDescriptor = MeshAllocator.vertexDescriptor()
        
        return try MTKMesh(mesh: mesh, device: MetalView.shared.device!)
    }    
}
