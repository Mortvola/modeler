//
//  MaterialEntry.swift
//  Terrain4
//
//  Created by Richard Shields on 3/25/23.
//

import Foundation

enum MaterialWrapper: Equatable, Codable {
    static func == (lhs: MaterialWrapper, rhs: MaterialWrapper) -> Bool {
        lhs.material.id == rhs.material.id
    }
    
    case pbrMaterial(PbrMaterial)
    case simpleMaterial(SimpleMaterial)
    case pointMaterial(PointMaterial)
    case billboardMaterial(BillboardMaterial)
    
    var id: UUID {
        material.id
    }
    
    var material: Material {
        switch(self) {
        case .pbrMaterial(let m):
            return m
        case .simpleMaterial(let m):
            return m
        case .pointMaterial(let m):
            return m
        case .billboardMaterial(let m):
            return m
        }
    }
    
    enum CodingKeys : CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "PBR":
            let m = try PbrMaterial(from: decoder)
            self = MaterialWrapper.pbrMaterial(m)
            return
        case "Simple":
            let m = try SimpleMaterial(from: decoder)
            self = MaterialWrapper.simpleMaterial(m)
            return
        default:
            break
        }

        throw Errors.invalidTexture
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .pbrMaterial(let m):
            try container.encode("PBR", forKey: .type)
            try m.encode(to: encoder)
        case .simpleMaterial(let m):
            try container.encode("Simple", forKey: .type)
            try m.encode(to: encoder)
        case .pointMaterial:
            throw Errors.invalidTexture
        case .billboardMaterial:
            throw Errors.invalidTexture
        }
    }
}

