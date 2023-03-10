//
//  Animators.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import Foundation

class Animator: ObservableObject, Identifiable, Equatable, Hashable {
    static func == (lhs: Animator, rhs: Animator) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: UUID
    
    @Published var name: String = ""
    @Published var delta: Vec3 = Vec3(0, 0, 0)
    var accum: Vec3 = Vec3(0, 0, 0)
    
    init() {
        self.id = UUID()
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
