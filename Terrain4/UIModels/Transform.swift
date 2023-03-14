//
//  Transform.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

class Transform: ObservableObject, Identifiable, Codable {
    let id: UUID
    
    enum TransformType: String, CaseIterable, Codable {
        case translate
        case rotate
        case scale
    }
    
    @Published var transform: TransformType = .translate
    @Published var values: Vec3 = Vec3(0, 0, 0)
    @Published var animator: Animator? = nil
    
    init() {
        self.id = UUID()
    }
    
    enum CodingKeys: CodingKey {
        case id
        case transform
        case values
        case animator
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = UUID()
        transform = try container.decode(TransformType.self, forKey: .transform)
        values = try container.decode(Vec3.self, forKey: .values)
        let animatorID = try container.decode(UUID.self, forKey: .animator)
        
        animator = AnimatorStore.shared.animators.first { anim in
            anim.id == animatorID
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(transform, forKey: .transform)
        try container.encode(values, forKey: .values)
        try container.encode(animator?.id, forKey: .animator)
    }
}
