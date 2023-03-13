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
            let material = try await MaterialManager.shared.addMaterial(device: device, view: view, name: .terrain)

            let sphere = try SphereAllocator.allocate(device: device, diameter: 5)
            
            object = Mesh(mesh: sphere, model: model)
            
            if let object = object {
                material.objects.append(object)
                model.objects.append(object)
            }

            break
            
        case .rectangle:
            let material = try await MaterialManager.shared.addMaterial(device: device, view: view, name: .terrain)

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
}
