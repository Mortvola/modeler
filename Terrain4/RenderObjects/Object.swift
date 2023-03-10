//
//  Object.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import Foundation

class Object: Identifiable, ObservableObject, Hashable {
    static func == (lhs: Object, rhs: Object) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()

    let model: Model
    
    var name: String

    var translation = vec3(0, 0, 0)
    
    var rotation = vec3(0, 0, 0)
    
    init (model: Model) {
        self.model = model
        self.name = "Object"
    }
    
    func modelMatrix() -> matrix_float4x4 {
        self.model.modelMatrix
    }
}
