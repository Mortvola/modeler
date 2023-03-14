//
//  Model.swift
//  Terrain
//
//  Created by Richard Shields on 3/1/23.
//

import Foundation

class Model: Identifiable, ObservableObject, Hashable, Codable {
    static func == (lhs: Model, rhs: Model) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    var name: String
    private static var modelCounter = 0

    @Published var objects: [RenderObject] = []

    @Published var lights: [Light] = []

    @Published var transforms: [Transform] = []

    var modelMatrix = Matrix4x4.identity()
    var translate = Vec3(0.0, 0.0, 0.0)
    var rotation: Float = 0.0

    init() {
        self.name = "Model_\(Model.modelCounter)"
        Model.modelCounter += 1
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case objects
        case lights
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        objects = try container.decode([Mesh].self, forKey: .objects)
        lights = try container.decode([Light].self, forKey: .lights)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(objects, forKey: .objects)
        try container.encode(lights, forKey: .lights)
    }

    func addLight() -> Light {
        let light = Light(model: self)
        light.intensity  = Vec3(50, 50, 50)
        
        self.lights.append(light)
        
        return light
    }
}
