//
//  Math.swift
//  Terrain
//
//  Created by Richard Shields on 2/24/23.
//

import Foundation

// Generic matrix math utility functions
func matrix4x4_identity() -> matrix_float4x4 {
    return matrix_float4x4.init(columns:(vector_float4(1, 0, 0, 0),
                                         vector_float4(0, 1, 0, 0),
                                         vector_float4(0, 0, 1, 0),
                                         vector_float4(0, 0, 0, 1)))
}

func matrix4x4_rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
    let unitAxis = normalize(axis)
    let ct = cosf(radians)
    let st = sinf(radians)
    let ci = 1 - ct
    let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
    return matrix_float4x4.init(columns:(vector_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                                         vector_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                                         vector_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                                         vector_float4(                  0,                   0,                   0, 1)))
}

func matrix4x4_translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> matrix_float4x4 {
    return matrix_float4x4.init(columns:(vector_float4(1, 0, 0, 0),
                                         vector_float4(0, 1, 0, 0),
                                         vector_float4(0, 0, 1, 0),
                                         vector_float4(translationX, translationY, translationZ, 1)))
}

func matrix4x4_scale(_ scaleX: Float, _ scaleY: Float, _ scaleZ: Float) -> matrix_float4x4 {
    return matrix_float4x4.init(columns:(vector_float4(scaleX, 0, 0, 0),
                                         vector_float4(0, scaleY, 0, 0),
                                         vector_float4(0, 0, scaleZ, 0),
                                         vector_float4(0, 0, 0, 1)))
}

//func matrix_perspective_right_hand(fovyRadians fovy: Float, aspect: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let ys = 1 / tanf(fovy * 0.5)
//    let xs = ys / aspect
//    let zs = 1 / (nearZ - farZ)
//    return matrix_float4x4.init(columns:(vector_float4(xs,  0, 0,   0),
//                                         vector_float4( 0, ys, 0,   0),
//                                         vector_float4( 0,  0, (farZ - nearZ) * zs, -1),
//                                         vector_float4( 0,  0, 2 * farZ * nearZ * zs, 0)))
//}

func matrix_perspective_left_hand(fovyRadians fovy: Float, aspect: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let ys = 1 / tanf(fovy * 0.5);
    let xs = ys * aspect;
    let zs = farZ / (farZ - nearZ);
    return matrix_float4x4(columns: (vector_float4(xs, 0, 0, 0),
                                     vector_float4(0, ys, 0, 0),
                                     vector_float4(0, 0, zs, 1),
                                     vector_float4(0, 0, -nearZ * zs, 0)))
}

func degreesToRadians(_ degrees: Float) -> Float {
    return (degrees / 180) * .pi
}

func degreesToRadians(_ degrees: Double) -> Double {
    return (degrees / 180) * .pi
}

func lookAt(offset: vec3, target: vec3, up: vec3) -> matrix_float4x4 {
    //    if (
    //      Math.abs(eyex - centerx) < glMatrix.EPSILON &&
    //      Math.abs(eyey - centery) < glMatrix.EPSILON &&
    //      Math.abs(eyez - centerz) < glMatrix.EPSILON
    //    ) {
    //      return identity(out);
    //    }
    let z = target
        .subtract(offset)
        .normalize()
    
    var x = up.cross(z)
    var lengthSquared = x.lengthSquared()
    if (lengthSquared == 0) {
        x = vec3(0, 0, 0)
    }
    else {
        let inverseLength = 1 / lengthSquared.squareRoot()
        x = x.multiply(inverseLength)
    }
    
    var y = z.cross(x)
    lengthSquared = y.lengthSquared()
    if (lengthSquared == 0) {
        y = vec3(0, 0, 0)
    }
    else {
        let inverseLength = 1 / lengthSquared.squareRoot()
        y = y.multiply(inverseLength)
    }
    
    let matrix = matrix_float4x4.init(columns: (
        vector_float4(x.x, y.x, z.x, 0),
        vector_float4(x.y, y.y, z.y, 0),
        vector_float4(x.z, y.z, z.z, 0),
        vector_float4(
            -(x.x * offset.x + x.y * offset.y + x.z * offset.z),
            -(y.x * offset.x + y.y * offset.y + y.z * offset.z),
            -(z.x * offset.x + z.y * offset.y + z.z * offset.z),
            1
        )
    ))

    return matrix;
}
