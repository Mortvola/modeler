//
//  ObjectStore.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

class ObjectStore: ObservableObject {
    static let shared = ObjectStore()
    
    @Published var models: [Model] = []
    @Published var selectedModel: Model? = nil
    @Published var selectedObject: RenderObject? = nil
    @Published var selectedLight: Light? = nil
    
    var lights: [Light] = []
    
    enum ObjectType: String, CaseIterable {
        case sphere
        case rectangle
        case skybox
        case light
        
        var name: String {rawValue}
    }
    
    func selectModel(_ model: Model?) {
        self.selectedModel = model
        self.selectedObject = nil
        self.selectedLight = nil
    }
    
    func selectObject(_ object: RenderObject?) {
        self.selectedModel = nil
        self.selectedObject = object
        self.selectedLight = nil
    }
    
    func selectLight(_ light: Light?) {
        self.selectedModel = nil
        self.selectedObject = nil
        self.selectedLight = light
    }
    
    @MainActor
    func addModel() {
        let model = Model()
        models.append(model)
        
        selectModel(model)
    }
    
    private func getModel() -> Model? {
        if let model = selectedObject?.model {
            return model
        }
        
        if let model = selectedLight?.model {
            return model
        }
        
        return selectedModel
    }
    
    @MainActor
    func addObject(type: ObjectStore.ObjectType) async throws {
        guard let device = Renderer.shared.device else {
            throw Errors.deviceNotSet
        }
        
        guard let view = Renderer.shared.view else {
            throw Errors.viewNotSet
        }
        
        guard let model = getModel() else {
            throw Errors.modelNotSelected
        }
        
        var object: RenderObject? = nil
        
        switch(type) {
        case .sphere:
            let material = try await MaterialManager.shared.addMaterial(device: device, view: view, material: nil)
            
            let sphere = try SphereAllocator.allocate(device: device, diameter: 5)
            
            object = Mesh(mesh: sphere, model: model)
            
            if let object = object {
                material.objects.append(object)
                model.objects.append(object)
            }
            
            break
            
        case .rectangle:
            let material = try await MaterialManager.shared.addMaterial(device: device, view: view, material: nil)
            
            object = try TestRectAllocator.allocate(device: device, model: model)
            
            if let object = object {
                material.objects.append(object)
                model.objects.append(object)
            }
            
            break
            
        case .skybox:
            break;
        case .light:
            break;
        }
        
        selectObject(object)
    }
    
    @MainActor
    func addLight() throws {
        guard let model = getModel() else {
            throw Errors.modelNotSelected
        }
        
        let light = model.addLight()
        self.lights.append(light)
        
        selectLight(light)
    }

    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

    func save() {
        let file = File()
        
        if let data = try? JSONEncoder().encode(file) {
            do {
                let url = getDocumentsDirectory().appendingPathComponent("Test.json")

//                print(url)
                try data.write(to: url)
            } catch {
                print("Error: Can't write categories")
            }
        }
    }
    
    @MainActor
    func open() async throws {
        let url = getDocumentsDirectory().appendingPathComponent("Test.json")

        print(url)
        
        if let data = try? Data(contentsOf: url) {
            do {
                let file = try JSONDecoder().decode(File.self, from: data)
                
                for material in MaterialStore.shared.materials {
                    material.materialEntry = try await MaterialManager.shared.addMaterial(device: Renderer.shared.device!, view: Renderer.shared.view!, material: material)
                }
                
                var newLights: [Light] = []
                
                for model in file.models {
                    for object in model.objects {
                        object.model = model

                        object.materialEntry = try await MaterialManager.shared.addMaterial(device: Renderer.shared.device!, view: Renderer.shared.view!, material: object.material)

                        object.materialEntry?.objects.append(object)
                    }
                    
                    model.lights.forEach { light in
                        newLights.append(light)
                    }
                }
                
                self.models = file.models
                self.lights = newLights

            } catch {
                print("Error: Can't decode contents of \(url): \(error)")
            }
        }
    }
}


struct File: Codable {
    struct Camera: Codable {
        var position: Vec3
        var yaw: Float
        var pitch: Float
        
        init(position: Vec3, yaw: Float, pitch: Float) {
            self.position = position
            self.yaw = yaw
            self.pitch = pitch
        }
        
        enum CodingKeys: CodingKey {
            case position
            case yaw
            case pitch
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.position = try container.decode(Vec3.self, forKey: .position)
            self.yaw = try container.decode(Float.self, forKey: .yaw)
            self.pitch = try container.decode(Float.self, forKey: .pitch)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(position, forKey: .position)
            try container.encode(yaw, forKey: .yaw)
            try container.encode(pitch, forKey: .pitch)
        }
    }

    var models: [Model]
    var animators: [Animator]
    var camera: Camera
    var materials: [Material]
    
    enum CodkingKeys: CodingKey {
        case models
        case animators
        case camera
        case materials
    }
    
    init() {
        self.models = ObjectStore.shared.models
        self.animators = AnimatorStore.shared.animators
        self.camera = Camera(position: Renderer.shared.camera.cameraOffset, yaw: Renderer.shared.camera.yaw, pitch: Renderer.shared.camera.pitch)
        self.materials = MaterialStore.shared.materials
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
        
        materials = try container.decode([Material].self, forKey: .materials)
        
        MaterialStore.shared.materials = materials
        
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
