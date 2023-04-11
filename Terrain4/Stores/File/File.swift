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

        // Encode each model to its own file
        makeModelsDirectory()
        
        for node in Renderer.shared.objectStore!.models {
            switch node.content {
            case .model(let model):
                let encodedModel = try JSONEncoder().encode(model)
                
                let url = getModelsDirectory().appendingPathComponent(model.id.uuidString)
                try encodedModel.write(to: url)
                
                print(url.absoluteString)
                break
            case .mesh:
                break
            case .point:
                break
            case .wireBox:
                break
            case .light:
                break
            case .directionalLight:
                break
            }
        }
        
        let modelIds: [UUID] = Renderer.shared.objectStore!.models.map { node in
            node.content.id
        }
        
        try container.encode(modelIds, forKey: .models)
        
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

        let modelIds = try container.decode([UUID].self, forKey: .models)
        
        for uuid in modelIds {
            let url = getModelsDirectory().appendingPathComponent(uuid.uuidString)
            
            let data = try Data(contentsOf: url)
            let model = try JSONDecoder().decode(Model.self, from: data)
            
            objectStore.models.append(TreeNode(model: model))
        }

        objectStore.scene.models = try container.decodeIfPresent([SceneModel].self, forKey: .scene) ?? []
        
        objectStore.directionalLight = try container.decodeIfPresent(DirectionalLight.self, forKey: .directionalLight) ?? DirectionalLight()
        
        objectStore.directionalLight.createShadowTexture()
    }
}

