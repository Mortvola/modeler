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
    
    var cameraOffset = Vec3(0.0, 0.0, -3.0)
    
    var cameraFront = defaultCameraFront
    
    var scale: Float = 1.0
    
    var moveDirection = Vec3(0.0, 0.0, 0.0)
    
    let velocity: Float = 1.1176 * 10 // meters per second
    
    var projectionMatrix = Matrix4x4()
    
    var world: World
    
    var width: Float?
    
    var height: Float?
    
    var nearZ: Float = 1.0
    
    var farZ: Float = 1600.0
    
    init(world: World) {
        self.world = world
        updateLookAt(yawChange: 0, pitchChange: 0)
    }
    
    func updateLookAt(yawChange: Float, pitchChange: Float) {
        self.yaw += yawChange
        self.pitch += pitchChange
        
        self.pitch = max(min(self.pitch, 89), -89)
        
        let cameraFront = defaultCameraFront
            .rotateX(degreesToRadians(self.pitch))
            .rotateY(degreesToRadians(self.yaw))
        
        self.cameraFront = cameraFront
    }
    
    func getViewMatrix() -> Matrix4x4 {
        let cameraTarget = self.cameraOffset
        //            .multiply(Vec3(self.scale, 1, self.scale))
            .add(self.cameraFront)
        
        let cameraUp = Vec3(0.0, 1.0, 0.0)
        
        let viewMatrix = Matrix4x4.lookAt(offset: cameraOffset, target: cameraTarget, up: cameraUp)
        
        return viewMatrix
        
        //        return simd_mul(
        //            matrix4x4_scale(self.scale, 1.0, self.scale),
        //            viewMatrix
        //        )
    }
    
    //    func test(_ matrix: Matrix4x4) {
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
        let direction = Vec3(x, y, z)
        
        let lengthSquared = direction.lengthSquared()
        
        if lengthSquared == 0 {
            self.moveDirection = Vec3(0, 0, 0)
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
        
        if let y = self.world.getElevation(x: self.cameraOffset.x, y: self.cameraOffset.z) {
            self.cameraOffset.y = y + 2
        }
    }
    
    func updateViewDimensions(width: Float, height: Float) {
        /// Respond to drawable size or orientation changes here
        self.width = width
        self.height = height
        
        let aspect = Float(height) / Float(width)
        self.projectionMatrix = Matrix4x4.perspectiveLeftHand(fovyRadians: degreesToRadians(45), aspect: aspect, nearZ: nearZ, farZ: farZ)
    }
    
    func createPerspectiveMatrix(nearZ zn: Float, farZ zf: Float) -> Matrix4x4 {
        let aspect = Float(height!) / Float(width!)
        return Matrix4x4.perspectiveLeftHand(fovyRadians: degreesToRadians(45), aspect: aspect, nearZ: zn, farZ: zf)
    }
    
    func getFustrumCorners(nearZ: Float, farZ: Float) -> [Vec4] {
        let cameraProjectionMatrix = createPerspectiveMatrix(nearZ: nearZ, farZ: farZ)
        let cameraViewMatrix = getViewMatrix()
        let cameraProjectionView = cameraProjectionMatrix * cameraViewMatrix
        
        let inverse = cameraProjectionView.inverse
        var cameraFustrum: [Vec4] = []
        
        // Create a box (8 points) in the camera's NDC coordinates and
        // transform the points into world space
        for z in [0, 1] {
            for y in [-1, 1] {
                for x in [-1, 1] {
                    let point = inverse * Vec4(Float(x), Float(y), Float(z), 1.0)
                    
                    cameraFustrum.append(point * (1 / point.w))
                }
            }
        }
        
        return cameraFustrum
    }
    
}
