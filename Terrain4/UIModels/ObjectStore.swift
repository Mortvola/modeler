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
    @Published var selectedModel: Model?

    private var modelCounter = 0
    private var objectCounter = 0
    
    enum ObjectType: String, CaseIterable {
        case sphere
        case rectangle
        case skybox
        case light
        
        var name: String {rawValue}
    }
    
    @MainActor
    func addModel() {
        let model = Model()
        model.name = "Model_\(modelCounter)"
        models.append(model)
        selectedModel = model
        
        self.modelCounter += 1
    }

    @MainActor
    func addObject(type: ObjectStore.ObjectType) async throws {
        guard let device = Renderer.shared.device else {
            throw Errors.deviceNotSet
        }
        
        guard let view = Renderer.shared.view else {
            throw Errors.viewNotSet
        }
        
        guard let model = self.selectedModel else {
            throw Errors.modelNotSelected
        }

        switch(type) {
        case .sphere:
            let material = try await MaterialManager.shared.addMaterial(device: device, view: view, name: .terrain)

            let sphere = try SphereAllocator.allocate(device: device, diameter: 5)
            
            let object = Mesh(mesh: sphere, model: model)
            object.name = "Sphere_\(objectCounter)"
            
            material.objects.append(object)
            model.objects.append(object)

            break
            
        case .rectangle:
            let material = try await MaterialManager.shared.addMaterial(device: device, view: view, name: .terrain)

            let object = try TestRectAllocator.allocate(device: device, model: model)
            object.name = "Rectangle_\(objectCounter)"
            
            material.objects.append(object)
            model.objects.append(object)
            
            break
            
        case .skybox:
            break;
        case .light:
            break;
        }
        
        self.objectCounter += 1
    }
}
