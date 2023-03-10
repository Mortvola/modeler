//
//  Transform.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

class Transform: ObservableObject, Identifiable {
    let id: UUID
    
    enum TransformType: String, CaseIterable, Codable {
        case translate
        case rotate
        case scale
    }
    
    @Published var transform: TransformType = .translate
    @Published var values: vec3 = vec3(0, 0, 0)
    @Published var animator: Animator? = nil
    
    init() {
        self.id = UUID()
    }
}
