//
//  TestRect.swift
//  Terrain
//
//  Created by Richard Shields on 3/1/23.
//

import Foundation
import Metal
import MetalKit
import Http

class TestRect: Model {
    init(device: MTLDevice, view: MTKView) async throws {
        super.init()
        
        let material = try await MaterialManager.shared.addMaterial(device: device, view: view, name: .terrain)
        let object: RenderObject = TriangleMesh(device: device, points: points, normals: normals, indices: indices, model: self)
        
        material.objects.append(object)
    }
}

private let points: [simd_float1] = [
    // South
    -10.0, 10.0,  10.0,  0.0, 0.0,
     10.0, 10.0,  10.0,  1.0, 0.0,
     10.0, -10.0, -10.0,  1.0, 1.0,
    -10.0, -10.0, -10.0,  0.0, 1.0
];

private let normals: [simd_float1] = [
    0.0, simd_float1(-1 / 2.0.squareRoot()), simd_float1(1 / 2.0.squareRoot()),
    0.0, simd_float1(-1 / 2.0.squareRoot()), simd_float1(1 / 2.0.squareRoot()),
    0.0, simd_float1(-1 / 2.0.squareRoot()), simd_float1(1 / 2.0.squareRoot()),
    0.0, simd_float1(-1 / 2.0.squareRoot()), simd_float1(1 / 2.0.squareRoot())
]

private let indices: [Int] = [
    0, 3, 2,
    2, 1, 0
]
