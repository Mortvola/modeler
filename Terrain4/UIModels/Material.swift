//
//  Material.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import Foundation

class Material: Identifiable, ObservableObject, Equatable, Hashable, Codable {
    static func == (lhs: Material, rhs: Material) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: UUID
    
    var name: String
    static var materialCounter = 0

    @Published var albedo: String = ""
    @Published var metalness: String = ""
    @Published var roughness: String = ""
    @Published var normals: String = ""
    
    var materialEntry: MaterialManager.MaterialEntry? = nil
    
    init() {
        id = UUID()
        name = "Material_\(Material.materialCounter)"
        Material.materialCounter += 1
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case albedo
        case normals
        case metalness
        case roughness
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        albedo = try container.decode(String.self, forKey: .albedo)
        normals = try container.decode(String.self, forKey: .normals)
        metalness = try container.decode(String.self, forKey: .metalness)
        roughness = try container.decode(String.self, forKey: .roughness)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(albedo, forKey: .albedo)
        try container.encode(metalness, forKey: .metalness)
        try container.encode(roughness, forKey: .roughness)
        try container.encode(normals, forKey: .normals)
    }
}
