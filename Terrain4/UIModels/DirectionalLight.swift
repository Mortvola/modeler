//
//  DirectionalLight.swift
//  Terrain4
//
//  Created by Richard Shields on 3/18/23.
//

import Foundation

class DirectionalLight: Node, Equatable {
    static func == (lhs: DirectionalLight, rhs: DirectionalLight) -> Bool {
        lhs === rhs
    }
    
    @Published var enabled = false
    @Published var direction = Vec3(0, -1, 1).normalize()
}
