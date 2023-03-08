//
//  Transform.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

class Transform: Identifiable, Codable {
    let id: UUID
    
    enum TransformType: String, CaseIterable, Codable {
        case translate
        case rotate
        case scale
    }
    
    var transform: TransformType = .translate
    var values: vec3 = vec3(0, 0, 0)
    var delta: vec3 = vec3(0, 0, 0)
    var accum: vec3 = vec3(0, 0, 0)

    init() {
        self.id = UUID()
    }
}
