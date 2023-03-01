//
//  Vec2.swift
//  Terrain
//
//  Created by Richard Shields on 2/28/23.
//

import Foundation

typealias vec2 = simd_float2

extension vec2 {
    func subtract(_ v: vec2) -> vec2 {
        vec2(self.x - v.x, self.y - v.y)
    }
}
