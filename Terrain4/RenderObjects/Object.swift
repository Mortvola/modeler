//
//  Object.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import Foundation

enum ObjectType: String, CaseIterable {
    case sphere
    case plane
    case box
    case cylinder
    case cone
    case light
    case point
    case billboard
    
    var name: String {rawValue}
}

class Object: Node, Identifiable, Hashable {
    static func == (lhs: Object, rhs: Object) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()

    var model: Model? = nil
    
    private static var objectCounter = 0

    @Published var translation = Vec3(0, 0, 0)
    
    @Published var rotation = Vec3(0, 0, 0)
    
    @Published var scale = Vec3(1, 1, 1)
    
    init (model: Model?) {
        self.model = model
        
        super.init(name: "Object_\(Object.objectCounter)")
        Object.objectCounter += 1
    }
    
    enum CodingKeys: CodingKey {
        case id
        case translation
        case rotation
        case scale
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        translation = try container.decode(Vec3.self, forKey: .translation)
        rotation = try container.decode(Vec3.self, forKey: .rotation)
        scale = try container.decode(Vec3.self, forKey: .scale)
        
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(translation, forKey: .translation)
            try container.encode(rotation, forKey: .rotation)
            try container.encode(scale, forKey: .scale)
            
            try super.encode(to: encoder)
        }
        catch {
            print(error)
            throw error
        }
    }

    func transformation() -> Matrix4x4 {
        Matrix4x4.identity()
            .translate(translation.x, translation.y, translation.z)
            .rotate(radians: degreesToRadians(rotation.x), axis: Vec3(1, 0, 0))
            .rotate(radians: degreesToRadians(rotation.y), axis: Vec3(0, 1, 0))
            .rotate(radians: degreesToRadians(rotation.z), axis: Vec3(0, 0, 1))
            .scale(scale.x, scale.y, scale.z)
    }
}
