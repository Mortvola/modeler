//
//  DirectionalLight.swift
//  Terrain4
//
//  Created by Richard Shields on 3/18/23.
//

import Foundation
import Metal

class DirectionalLight: Node, Equatable {
    static func == (lhs: DirectionalLight, rhs: DirectionalLight) -> Bool {
        lhs === rhs
    }
    
    @Published var enabled = false
    @Published var direction = Vec3(0, -1, 1).normalize()
    @Published var intensity = Vec3(15, 15, 15)
    @Published var shadowCaster = true
    
    var shadowTexture: MTLTexture?
    
    func getViewMatrix() -> Matrix4x4 {
        let position = -direction * 75
        let target = Vec3(0, 0, 0)
        let up = Vec3(0.0, 1.0, 0.0)
        
        return Matrix4x4.lookAt(offset: position, target: target, up: up)
    }
    
    func getProjectionViewMatrix() -> Matrix4x4 {
        Matrix4x4
            .orthographic(left: -30, right: 30, top: 30, bottom: -30, near: 0, far: 100)
            .multiply(ObjectStore.shared.directionalLight.getViewMatrix())
    }
}
