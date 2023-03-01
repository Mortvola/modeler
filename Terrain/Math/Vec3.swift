//
//  Vec3.swift
//  Terrain
//
//  Created by Richard Shields on 2/26/23.
//

import Foundation

typealias vec3 = simd_float3

extension vec3 {
    func rotateX(_ radians: Float) -> vec3 {
        vec3 (
            self.x,
            self.y * cos(radians) - self.z * sin(radians),
            self.y * sin(radians) + self.z * cos(radians)
        )
    }
    
    func rotateY(_ radians: Float) -> vec3 {
        vec3 (
            self.z * sin(radians) + self.x * cos(radians),
            self.y,
            self.z * cos(radians) - self.x * sin(radians)
        )
    }
    
    func rotateZ(_ radians: Float) -> vec3 {
        vec3 (
            self.x * cos(radians) - self.y * sin(radians),
            self.x * sin(radians) + self.y * cos(radians),
            self.z
        )
    }
    
    func multiply(_ v: vec3) -> vec3 {
        vec3(self.x * v.x, self.y * v.y, self.z * v.z)
    }
    
    func multiply(_ v: Float) -> vec3 {
        vec3(self.x * v, self.y * v, self.z * v)
    }

    func add(_ v: vec3) -> vec3 {
        vec3(self.x + v.x, self.y + v.y, self.z + v.z)
    }
    
    func subtract(_ v: vec3) -> vec3 {
        vec3(self.x - v.x, self.y - v.y, self.z - v.z)
    }
    
    func normalize() -> vec3 {
        simd_normalize(self)
    }
    
    func length() -> Float {
        lengthSquared().squareRoot()
    }
    
    func lengthSquared() -> Float {
        simd_length_squared(self)
    }
    
    func cross(_ other: vec3) -> vec3 {
        simd_cross(self, other)
    }
}
