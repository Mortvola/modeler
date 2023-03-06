//
//  Camera.swift
//  Terrain
//
//  Created by Richard Shields on 2/26/23.
//

import Foundation

let defaultCameraFront = simd_float3(0.0, 0.0, 1.0)

class Camera {
    var yaw: Float = 0.0
    
    var pitch: Float = 0.0
    
//    var cameraOffset = vec3(0.0, simd_float1(1 / 2.0.squareRoot()), -simd_float1(1 / 2.0.squareRoot()))
    var cameraOffset = vec3(0.0, 2.0, 0.0)

    var cameraFront = defaultCameraFront
    
    var scale: Float = 1.0
    
    var moveDirection = vec3(0.0, 0.0, 0.0)
    
    let velocity: Float = 1.1176 * 10; // meters per second

    var projectionMatrix: matrix_float4x4 = matrix_float4x4()
    
    var world: World
    
    init(world: World) {
        self.world = world
        updateLookAt(yawChange: 0, pitchChange: 0)
    }
    
    func updateLookAt(yawChange: Float, pitchChange: Float) {
        self.yaw += yawChange
        self.pitch += pitchChange
        
        self.pitch = max(min(self.pitch, 89), -89);
        
        let cameraFront = defaultCameraFront
            .rotateX(degreesToRadians(self.pitch))
            .rotateY(degreesToRadians(self.yaw))
        
        self.cameraFront = cameraFront
    }
    
    func getViewMatrix() -> matrix_float4x4 {
        let cameraTarget = self.cameraOffset
//            .multiply(vec3(self.scale, 1, self.scale))
            .add(self.cameraFront)
        
        let cameraUp = vec3(0.0, 1.0, 0.0)
        
        let viewMatrix = lookAt(offset: cameraOffset, target: cameraTarget, up: cameraUp)
        
        return simd_mul(
            matrix4x4_scale(self.scale, 1.0, self.scale),
            viewMatrix
        )
    }
    
//    func test(_ matrix: matrix_float4x4) {
//        let p = simd_float4(10.0, 2510.0, 10, 1.0)
//
//        let s = simd_mul(matrix, p)
//
//        print("s: \(s), yaw: \(self.yaw), pitch: \(self.pitch)")
//        print("s length: \(simd_length(s))")
//
//        let m = simd_mul(
//            projectionMatrix,
//            matrix
//        )
//
//        let t = simd_mul(m, p)
//
//        print("t: \(t)")
//        print("t / t.w: \(t.x / t.w), \(t.y / t.w), \(t.z / t.w)")
//    }
    
    func setMoveDirection(x: Float, y: Float, z: Float) {
        let direction = vec3(x, y, z)
    
        let lengthSquared = direction.lengthSquared()
        
        if lengthSquared == 0 {
            self.moveDirection = vec3(0, 0, 0)
        }
        else {
            self.moveDirection = direction.multiply(1 / lengthSquared.squareRoot())
        }
    }
    
    func updatePostion(elapsedTime: Double) {
        let v = self.moveDirection
            .rotateY(degreesToRadians(self.yaw))
            .multiply(self.velocity * Float(elapsedTime))

        self.cameraOffset = self.cameraOffset.add(v)
        
        self.cameraOffset.y = self.world.getElevation(x: self.cameraOffset.x, y: self.cameraOffset.z);
    }
    
    func updateViewDimensions(width: Float, height: Float) {
        /// Respond to drawable size or orientation changes here
        
        let aspect = Float(height) / Float(width)
        self.projectionMatrix = matrix_perspective_left_hand(fovyRadians: degreesToRadians(45), aspect: aspect, nearZ: 1, farZ: 16000.0)
    }
}
