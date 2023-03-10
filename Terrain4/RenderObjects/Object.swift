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

    var translation = Vec3(0, 0, 0)
    
    var rotation = Vec3(0, 0, 0)
    
    init (model: Model) {
        self.model = model
        self.name = "Object_\(Object.objectCounter)"
        Object.objectCounter += 1
    }
    
    func modelMatrix() -> Matrix4x4 {
        self.model.modelMatrix.multiply(Matrix4x4.translation(translation.x, translation.y, translation.z)).multiply(Matrix4x4.rotation(radians: degreesToRadians(rotation.x), axis: Vec3(1, 0, 0))).multiply(Matrix4x4.rotation(radians: degreesToRadians(rotation.y), axis: Vec3(0, 1, 0))).multiply(Matrix4x4.rotation(radians: degreesToRadians(rotation.z), axis: Vec3(0, 0, 1)))
    }
}