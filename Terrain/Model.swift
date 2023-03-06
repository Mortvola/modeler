//
//  Model.swift
//  Terrain
//
//  Created by Richard Shields on 3/1/23.
//

import Foundation

class Model {
    var modelMatrix = matrix4x4_identity()
    var translate = vec3(0.0, 0.0, 0.0)

    func setTranslation(x: Float, y: Float, z: Float) {
        self.translate = vec3(x, y, z);
        self.makeModelMatrix();
    }
    
    func setRotationY(radians: Float, axis: vec3) {
        self.modelMatrix = matrix4x4_rotation(radians: radians, axis: axis)
    }
    
    func makeModelMatrix() {
        self.modelMatrix = matrix4x4_translation(self.translate.x, self.translate.y, self.translate.z)
    }
}
