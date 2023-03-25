//
//  MaterialDescriptor.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

class MaterialDescriptor: Codable {
    var id: UUID

    var name: String
    
    var albedo: AlbedoLayerDescriptor
    var normals: NormalsLayerDescriptor
    var metallic: MetallicLayerDescriptor
    var roughness: RoughnessLayerDescriptor
    
    init() {
        self.id = UUID()
        self.name = ""
        
        self.albedo = AlbedoLayerDescriptor()
        self.normals = NormalsLayerDescriptor()
        self.metallic = MetallicLayerDescriptor()
        self.roughness = RoughnessLayerDescriptor()
    }
    
    init(material: PbrMaterial) {
        self.id = material.id
        self.name = material.name

        self.albedo = AlbedoLayerDescriptor(albedoLayer: material.albedo)
        self.normals = NormalsLayerDescriptor(normalsLayer: material.normals)
        self.metallic = MetallicLayerDescriptor(metallicLayer: material.metallic)
        self.roughness = RoughnessLayerDescriptor(roughnessLayer: material.roughness)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case albedo
        case normals
        case metallic
        case roughness
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        albedo = try container.decode(AlbedoLayerDescriptor.self, forKey: .albedo)
        normals = try container.decode(NormalsLayerDescriptor.self, forKey: .normals)
        metallic = try container.decode(MetallicLayerDescriptor.self, forKey: .metallic)
        roughness = try container.decode(RoughnessLayerDescriptor.self, forKey: .roughness)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        
        try container.encode(albedo, forKey: .albedo)
        try container.encode(metallic, forKey: .metallic)
        try container.encode(roughness, forKey: .roughness)
        try container.encode(normals, forKey: .normals)
    }
}
