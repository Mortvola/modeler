//
//  BillboardAllocator.swift
//  Terrain4
//
//  Created by Richard Shields on 3/25/23.
//

import Foundation
import MetalKit

class BillboardAllocator {
    static func allocate(model: Model) throws -> Mesh {
        let points: [Float] = [
            -1, 1, 0,
             1, 1, 0,
             1, -1, 0,
             -1, -1, 0
        ]
        let texcoords: [Float] = [
            0, 0,
            1, 0,
            1, 1,
            0, 1
        ]
        let normals: [Float] = [
            0, 0, -1,
            0, 0, -1,
            0, 0, -1,
            0, 0, -1
        ]
        let submeshes: [Mesh.Submesh] = [Mesh.Submesh(
            primitiveType: 3,
            indexes: [0, 1, 3, 1, 2, 3]
        )]
        
        
        return try Mesh(points: points, texcoords: texcoords, normals: normals, submeshes: submeshes, model: model)
    }    
}
