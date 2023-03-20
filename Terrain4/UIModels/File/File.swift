//
//  File.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

struct File: Codable {
    var models: [Model]
    var animators: [Animator]
    var camera: Camera
    var materials: [MaterialDescriptor]
    
    enum CodkingKeys: CodingKey {
        case models
        case animators
        case camera
        case materials
    }
    
    init(file: SceneDocument) {
        self.models = file.objectStore.models
        self.animators = AnimatorStore.shared.animators
        self.camera = Camera(position: Renderer.shared.camera.cameraOffset, yaw: Renderer.shared.camera.yaw, pitch: Renderer.shared.camera.pitch)
        self.materials = []
        
        self.materials = MaterialManager.shared.materials.compactMap { material in
            if material.key == nil {
                return nil
            }
        
            return MaterialDescriptor(material: material.value.material)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        camera = try container.decode(Camera.self, forKey: .camera)
        
        Renderer.shared.camera.cameraOffset = camera.position
        Renderer.shared.camera.yaw = camera.yaw
        Renderer.shared.camera.pitch = camera.pitch
        
        Renderer.shared.camera.updateLookAt(yawChange: 0, pitchChange: 0)

        animators = try container.decode([Animator].self, forKey: .animators)
        
        AnimatorStore.shared.animators = animators
        
        materials = try container.decode([MaterialDescriptor].self, forKey: .materials)
        
        models = try container.decode([Model].self, forKey: .models)
    }
    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodkingKeys.self)
//
//        try container.encode(self.camera, forKey: .camera)
//        try container.encode(self.animators, forKey: .animators)
//        try container.encode(self.models, forKey: .models)
//    }
}
