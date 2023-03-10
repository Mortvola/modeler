//
//  TestRectAllocator.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import Foundation
import Metal
import MetalKit

class TestRectAllocator {
    static func allocate(device: MTLDevice, model: Model) throws -> RenderObject {
        TriangleMesh(device: device, points: points, normals: normals, indices: indices, model: model)
    }
}

private let points: [simd_float1] = [
    // South
    -10.0, 0.0,  10.0,  0.0, 1.0,
     10.0, 0.0,  10.0,  1.0, 1.0,
     10.0, 0.0, -10.0,  1.0, 0.0,
    -10.0, 0.0, -10.0,  0.0, 0.0
];

private let normals: [simd_float1] = [
    0.0, -1, 0,
    0.0, -1, 0,
    0.0, -1, 0,
    0.0, -1, 0,
]

private let indices: [Int] = [
    0, 2, 3,
    0, 1, 2
]
