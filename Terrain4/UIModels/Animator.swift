//
//  Animators.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import Foundation

class Animator: Node, Identifiable, Equatable, Hashable, Codable {
    static func == (lhs: Animator, rhs: Animator) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: UUID
    
    @Published var delta: Vec3 = Vec3(0, 0, 0)
    var accum: Vec3 = Vec3(0, 0, 0)
    
    init() {
        self.id = UUID()
        
        super.init(name: "")
    }
    
//    convenience init(name: String) {
//        self.init()
//        self.name = name
//    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case delta
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try container.decode(String.self, forKey: .name)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.delta = try container.decode(Vec3.self, forKey: .delta)

        super.init(name: name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.delta, forKey: .delta)
    }
}
