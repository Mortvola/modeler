//
//  File.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

struct File: Codable {
    var camera: Camera
    
    init(file: SceneDocument) {
        self.camera = Camera(position: Renderer.shared.camera.cameraOffset, yaw: Renderer.shared.camera.yaw, pitch: Renderer.shared.camera.pitch)
    }

    enum CodingKeys: CodingKey {
        case models
        case animators
        case camera
        case materials
        case directionalLight
        case scene
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(Renderer.shared.objectStore!.models, forKey: .models)
        try container.encode(self.camera, forKey: .camera)
        
        let materials = Renderer.shared.materialManager.materials.compactMap { entry in
            entry.value
        }

        try container.encode(materials, forKey: .materials)
        
        try container.encode(Renderer.shared.objectStore!.directionalLight, forKey: .directionalLight)
        
        try container.encode(Renderer.shared.objectStore!.scene.models, forKey: .scene)
        
        try container.encode(Renderer.shared.objectStore!.animators, forKey: .animators)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        camera = try container.decode(Camera.self, forKey: .camera)
        
        Renderer.shared.camera.cameraOffset = camera.position
        Renderer.shared.camera.yaw = camera.yaw
        Renderer.shared.camera.pitch = camera.pitch
        Renderer.shared.camera.updateLookAt(yawChange: 0, pitchChange: 0)
        
        let objectStore = decoder.getObjectStore()
        
        objectStore.animators = try container.decodeIfPresent([Animator].self, forKey: .animators) ?? []
        
        let materials = try container.decode([MaterialWrapper].self, forKey: .materials)
        
        for material in materials {
            Renderer.shared.materialManager.materials[material.material.id] = material
        }

        objectStore.models = try container.decode([TreeNode].self, forKey: .models)
        
        objectStore.scene.models = try container.decodeIfPresent([SceneModel].self, forKey: .scene) ?? []
        
        objectStore.directionalLight = try container.decodeIfPresent(DirectionalLight.self, forKey: .directionalLight) ?? DirectionalLight()
        
        objectStore.directionalLight.createShadowTexture()
    }
}

