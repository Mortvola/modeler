//
//  ObjectStore.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

enum SelectedNode: Equatable {
    static func == (lhs: SelectedNode, rhs: SelectedNode) -> Bool {
        switch lhs {
        case .model(let m1):
            switch rhs {
            case .model(let m2):
                return m2 == m1
            default:
                return false
            }
        case .object(let o1):
            switch rhs {
            case .object(let o2):
                return o1 == o2
            default:
                return false
            }
        case .light(let l1):
            switch rhs {
            case .light(let l2):
                return l1 == l2
            default:
                return false
            }
        case .directLight(let d1):
            switch rhs {
            case .directLight(let d2):
                return d1 == d2
            default:
                return false
            }
        }
    }
    
    case model(Model)
    case object(RenderObject)
    case light(Light)
    case directLight(DirectionalLight)
}

class Node: ObservableObject {
    @Published var name: String
    @Published var disabled = false
    
    init(name: String) {
        self.name = name
    }
    
//    enum CodingKeys: CodingKey {
//        case name
//    }
//
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        name = try container.decode(String.self, forKey: .name)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        try container.encode(name, forKey: .name)
//    }
}

class ObjectStore: ObservableObject {
    static let shared = ObjectStore()
    
    @Published var models: [Model] = []
    @Published var selectedNode: SelectedNode? = nil
//    @Published var selectedObject: RenderObject? = nil
//    @Published var selectedLight: Light? = nil
    
    var lights: [Light] = []
    var directionalLight = DirectionalLight(name: "Directional Light")
    
    @Published  var skybox: Skybox?
    
    enum ObjectType: String, CaseIterable {
        case sphere
        case rectangle
        case light
        
        var name: String {rawValue}
    }
    
    func selectModel(_ model: Model?) {
        if let model = model {
            self.selectedNode = SelectedNode.model(model)
        }
        else {
            self.selectedNode = nil
        }
    }
    
    func selectObject(_ object: RenderObject?) {
        if let object = object {
            self.selectedNode = SelectedNode.object(object)
        }
        else {
            self.selectedNode = nil
        }
    }
    
    func selectLight(_ light: Light?) {
        if let light = light {
            self.selectedNode = SelectedNode.light(light)
        }
        else {
            self.selectedNode = nil
        }
    }
    
    func selectDirectionalLight() {
        self.selectedNode = SelectedNode.directLight(self.directionalLight)
    }
    
    @MainActor
    func addModel() {
        let model = Model()
        models.append(model)
        
        selectModel(model)
    }
    
    private func getModel() -> Model? {
        if let selectedNode = selectedNode {
            switch selectedNode {
            case .model(let m):
                return m;
            case .object(let o):
                return o.model;
            case .light(let l):
                return l.model
            case .directLight:
                return nil
            }
        }

        return nil
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
            let material = try await MaterialManager.shared.addMaterial(device: device, view: view, descriptor: nil)
            
            let mesh = try SphereAllocator.allocate(device: device, diameter: 5)
            
            object = Mesh(mesh: mesh, model: model)
            
            if let object = object {
                material.objects.append(object)
                model.objects.append(object)
            }
            
            break
            
        case .rectangle:
            let material = try await MaterialManager.shared.addMaterial(device: device, view: view, descriptor: nil)
            
            let dimensions = Vec2(5, 5)
            let segments = VecUInt2(5, 5)
            let mesh = try RetangleAllocator.allocate(device: device, dimensions: dimensions, segments: segments)
            
            object = Mesh(mesh: mesh, model: model)

            if let object = object {
                material.objects.append(object)
                model.objects.append(object)
            }
            
            break
            
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
    
    @MainActor
    func addSkybox() async throws {
        try await self.skybox = Skybox(device: Renderer.shared.device!, view: Renderer.shared.view!)
    }

    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}
