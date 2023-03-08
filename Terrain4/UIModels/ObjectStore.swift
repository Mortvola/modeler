//
//  ObjectStore.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

class ObjectStore: ObservableObject {
    static let shared = ObjectStore()
    
    @Published var objects: [Model] = []
    private var counter = 0
    
    enum ObjectType: String, CaseIterable {
        case sphere
        case rectangle
        case skybox
        
        var name: String {rawValue}
    }
    
    @MainActor
    func addObject(type: ObjectStore.ObjectType) async throws {
        guard let device = Renderer.shared.device else {
            throw Errors.deviceNotSet
        }
        
        guard let view = Renderer.shared.view else {
            throw Errors.viewNotSet
        }

        switch(type) {
        case .sphere:
            let object = try await Sphere(device: device, view: view, diameter: 5)
            object.name = "Sphere_\(self.counter)"
            self.objects.append(object)
            break
            
        case .rectangle:
            let object = try await TestRect(device: device, view: view)
            object.name = "Rectangle_\(self.counter)"
            self.objects.append(object)
            break
        case .skybox:
            break;
        }
        
        self.counter += 1
    }
}
