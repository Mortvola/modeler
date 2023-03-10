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
    private static var objectCounter = 0

    var translation = vec3(0, 0, 0)
    
    var rotation = vec3(0, 0, 0)
    
    init (model: Model) {
        self.model = model
        self.name = "Object_\(Object.objectCounter)"
        Object.objectCounter += 1
    }
    
    func modelMatrix() -> matrix_float4x4 {
        matrix_multiply(self.model.modelMatrix,
                            matrix_multiply(matrix4x4_translation(translation.x, translation.y, translation.z),
                            matrix_multiply(
                                matrix_multiply(
                                    matrix4x4_rotation(radians: degreesToRadians(rotation.x), axis: vec3(1, 0, 0)),
                                    matrix4x4_rotation(radians: degreesToRadians(rotation.y), axis: vec3(0, 1, 0))
                                ),
                                matrix4x4_rotation(radians: degreesToRadians(rotation.z), axis: vec3(0, 0, 1))
                            )
                        )
                    )
    }
}
