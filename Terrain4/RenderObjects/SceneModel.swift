//
//  SceneModel.swift
//  Terrain4
//
//  Created by Richard Shields on 3/27/23.
//

import Foundation

class Animator: Codable {
    enum AnimatorType: Codable {
    case rotateX
    case rotateY
    case rotateZ
    }
    
    var id: UUID
    var type: AnimatorType
    var value: Float = 0.0
    var accum: Float = 0.0
    
    var name: String {
        switch type {
        case .rotateX:
            return "Rotate X"
        case .rotateY:
            return "Rotate Y"
        case .rotateZ:
            return "Rotate Z"
        }
    }
    
    init(type: AnimatorType) {
        id = UUID()
        self.type = type
    }
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(AnimatorType.self, forKey: .type)
        value = try container.decode(Float.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(value, forKey: .value)
    }
}

class SceneModel: ObservableObject, Identifiable, Equatable, Codable {
    static func == (lhs: SceneModel, rhs: SceneModel) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    
    @Published var name = ""
    
    var model: Model? = nil

    @Published var animators: [Animator] = []

    @Published var translation = Vec3(0, 0, 0)
    
    @Published var rotation = Vec3(0, 0, 0)
    
    @Published var scale = Vec3(1, 1, 1)
    
    init(model: Model) {
        self.model = model
    }
    
    enum CodingKeys: CodingKey {
        case name
        case translation
        case rotation
        case scale
        case model
        case animators
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        translation = try container.decode(Vec3.self, forKey: .translation)
        rotation = try container.decode(Vec3.self, forKey: .rotation)
        scale = try container.decode(Vec3.self, forKey: .scale)

        let objectStore = decoder.getObjectStore()

        let modelId = try container.decode(UUID.self, forKey: .model)

        let node = objectStore.models.first {
            $0.content.id == modelId
        }
        
        if let node = node {
            switch node.content {
            case .model(let m):
                model = m
            default:
                break
            }
        }
        
        let animatorIds = try container.decode([UUID].self, forKey: .animators)
        
        for id in animatorIds {
            let animator = objectStore.animators.first {
                $0.id == id
            }
            
            if let animator = animator {
                animators.append(animator)
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(model!.id, forKey: .model)
        try container.encode(translation, forKey: .translation)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(scale, forKey: .scale)
        
        let animatorIds = animators.map {
            $0.id
        }
        
        try container.encode(animatorIds, forKey: .animators)
    }

    func transformation() -> Matrix4x4 {
        Matrix4x4.identity()
            .translate(translation.x, translation.y, translation.z)
            .rotate(radians: degreesToRadians(rotation.x), axis: Vec3(1, 0, 0))
            .rotate(radians: degreesToRadians(rotation.y), axis: Vec3(0, 1, 0))
            .rotate(radians: degreesToRadians(rotation.z), axis: Vec3(0, 0, 1))
            .scale(scale.x, scale.y, scale.z)
    }
    
    func addAnimator(animator: Animator) {
        Renderer.shared.objectStore!.animators.append(animator)
        animators.append(animator)
    }
}
