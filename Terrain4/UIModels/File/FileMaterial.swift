//
//  Material.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

extension File {
    class Material: Codable {
        var id: UUID

        var name = ""
        
        var albedo: AlbedoLayer
        var normals: NormalsLayer
        var metallic: MetallicLayer
        var roughness: RoughnessLayer
        
        init(material: Terrain4.PbrMaterial) {
            self.id = material.id
            self.name = material.name
            
            self.albedo = AlbedoLayer(albedo: material.albedo)
            self.normals = NormalsLayer(normals: material.normals)
            self.metallic = MetallicLayer(metallic: material.metallic)
            self.roughness = RoughnessLayer(roughness: material.roughness)
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
            albedo = try container.decode(AlbedoLayer.self, forKey: .albedo)
            normals = try container.decode(NormalsLayer.self, forKey: .normals)
            metallic = try container.decode(MetallicLayer.self, forKey: .metalness)
            roughness = try container.decode(RoughnessLayer.self, forKey: .roughness)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(albedo, forKey: .albedo)
            try container.encode(metallic, forKey: .metalness)
            try container.encode(roughness, forKey: .roughness)
            try container.encode(normals, forKey: .normals)
        }
    }
}
