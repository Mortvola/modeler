//
//  Model.swift
//  Terrain
//
//  Created by Richard Shields on 3/1/23.
//

import Foundation

class Model: Node, Identifiable, Hashable, Codable {
    static func == (lhs: Model, rhs: Model) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    private static var modelCounter = 0
    
    @Published var objects: [RenderObject] = []
    
    @Published var lights: [Light] = []
    
    @Published var transforms: [Transform] = []
    
    var modelMatrix = Matrix4x4.identity()
    var translate = Vec3(0.0, 0.0, 0.0)
    var rotation: Float = 0.0
    
    init() {
        super.init(name: "Model_\(Model.modelCounter)")
        Model.modelCounter += 1
        
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case objects
        case lights
        case transforms
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try container.decode(String.self, forKey: .name)
        
        super.init(name: name)
        
        id = try container.decode(UUID.self, forKey: .id)
        objects = try container.decode([Mesh].self, forKey: .objects)
        lights = try container.decode([Light].self, forKey: .lights)
        transforms = try container.decode([Transform].self, forKey: .transforms)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(objects, forKey: .objects)
        try container.encode(lights, forKey: .lights)
        try container.encode(transforms, forKey: .transforms)
    }
    
    func addLight() -> Light {
        let light = Light(model: self)
        light.intensity  = Vec3(50, 50, 50)
        
        self.lights.append(light)
        
        return light
    }
    
    @MainActor
    func addObject(type: ObjectStore.ObjectType) async throws -> RenderObject? {
        guard let device = Renderer.shared.device else {
            throw Errors.deviceNotSet
        }
        
        guard let view = Renderer.shared.view else {
            throw Errors.viewNotSet
        }
                
        var object: RenderObject? = nil
        
        switch(type) {
        case .sphere:
            let material = try await MaterialManager.shared.addMaterial(device: device, view: view, descriptor: nil)
            
            let mesh = try SphereAllocator.allocate(device: device, diameter: 5)
            
            object = Mesh(mesh: mesh, model: self)
            
            if let object = object {
                material.objects.append(object)
                self.objects.append(object)
            }
            
            break
            
        case .rectangle:
            let material = try await MaterialManager.shared.addMaterial(device: device, view: view, descriptor: nil)
            
            let dimensions = Vec2(5, 5)
            let segments = VecUInt2(5, 5)
            let mesh = try RetangleAllocator.allocate(device: device, dimensions: dimensions, segments: segments)
            
            object = Mesh(mesh: mesh, model: self)

            if let object = object {
                material.objects.append(object)
                self.objects.append(object)
            }
            
            break
            
        case .light:
            break;
        }
        
        return object
    }
}
