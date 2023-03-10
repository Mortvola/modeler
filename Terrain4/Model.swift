//
//  Model.swift
//  Terrain
//
//  Created by Richard Shields on 3/1/23.
//

import Foundation

class Model: Identifiable, ObservableObject, Hashable {
    static func == (lhs: Model, rhs: Model) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    var name: String
    private static var modelCounter = 0

    @Published var objects: [RenderObject] = []
    
    @Published var transforms: [Transform] = []
    
    var modelMatrix = Matrix4x4.identity()
    var translate = Vec3(0.0, 0.0, 0.0)
    var rotation: Float = 0.0
    
    init() {
        self.name = "Model_\(Model.modelCounter)"
        Model.modelCounter += 1
    }
//    func setTranslation(x: Float, y: Float, z: Float) {
//        self.translate = Vec3(x, y, z);
//        self.makeModelMatrix();
//    }
//
//    func setRotationY(radians: Float, axis: Vec3) {
//        self.modelMatrix = Matrix4x4.rotation(radians: radians, axis: axis)
//    }
//
//    func makeModelMatrix() {
//        self.modelMatrix = matrix4x4_translation(self.translate.x, self.translate.y, self.translate.z)
//    }
}
