//
//  File.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

struct File: Codable {
    var models: [TreeNode]
    var animators: [Animator]
    var camera: Camera
    var materials: [MaterialWrapper]
    var directionalLight: DirectionalLight
    
    init(file: SceneDocument) {
        self.models = file.objectStore.models
        self.animators = AnimatorStore.shared.animators
        self.camera = Camera(position: Renderer.shared.camera.cameraOffset, yaw: Renderer.shared.camera.yaw, pitch: Renderer.shared.camera.pitch)
        
        self.materials = Renderer.shared.materialManager.materials.compactMap { entry in
            entry.value
        }

        self.directionalLight = file.objectStore.directionalLight
    }

    enum CodingKeys: CodingKey {
        case models
        case animators
        case camera
        case materials
        case directionalLight
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.models, forKey: .models)
        try container.encode(self.camera, forKey: .camera)
        try container.encode(self.animators, forKey: .animators)
        try container.encode(self.materials, forKey: .materials)
        try container.encode(self.directionalLight, forKey: .directionalLight)
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
        
        materials = try container.decode([MaterialWrapper].self, forKey: .materials)
        
        for material in materials {
            Renderer.shared.materialManager.materials[material.material.id] = material
        }

        models = try container.decode([TreeNode].self, forKey: .models)
        
        directionalLight = try container.decodeIfPresent(DirectionalLight.self, forKey: .directionalLight) ?? DirectionalLight()
    }
}

