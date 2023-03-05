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

class TestMesh: Model {
    init(device: MTLDevice, view: MTKView) async throws {
        super.init()
        
        let material = try await MaterialManager.shared.addMaterial(device: device, view: view, name: .pbrLine)
        
        for z in stride(from: -10, to: 11, by: 1) {
            var points: [Float] = []
            
            for x in stride(from: -10, to: 11, by: 1) {
                points.append(Float(x))
                points.append(Float(z))
                points.append(0)
            }

            let object: RenderObject = Line(device: device, points: points, model: self)
            
            material.objects.append(object)
        }

        for x in stride(from: -10, to: 11, by: 1) {
            var points: [Float] = []
            
            for z in stride(from: -10, to: 11, by: 1) {
                points.append(Float(x))
                points.append(Float(z))
                points.append(0)
            }

            let object: RenderObject = Line(device: device, points: points, model: self)
            
            material.objects.append(object)
        }
    }
}
