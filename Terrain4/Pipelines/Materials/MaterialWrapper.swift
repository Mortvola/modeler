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
    case graphMaterial(GraphMaterial)
    case pointMaterial(PointMaterial)
    case billboardMaterial(BillboardMaterial)
    case lineMaterial(LineMaterial)
    
    var id: UUID {
        material.id
    }
    
    var material: Material {
        switch(self) {
        case .pbrMaterial(let m):
            return m
        case .graphMaterial(let m):
            return m
        case .pointMaterial(let m):
            return m
        case .billboardMaterial(let m):
            return m
        case .lineMaterial(let m):
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
        case "Graph":
            let m = try GraphMaterial(from: decoder)
            self = MaterialWrapper.graphMaterial(m)
            return
        case "Simple":
            let m = try GraphMaterial(from: decoder)
            self = MaterialWrapper.graphMaterial(m)
            return
        case "Billboard":
            let m = try BillboardMaterial(from: decoder)
            self = MaterialWrapper.billboardMaterial(m)
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
        case .graphMaterial(let m):
            try container.encode("Graph", forKey: .type)
            try m.encode(to: encoder)
        case .pointMaterial:
            throw Errors.invalidTexture
        case .billboardMaterial(let m):
            try container.encode("Billboard", forKey: .type)
            try m.encode(to: encoder)
        case .lineMaterial(let m):
            try container.encode("Line", forKey: .type)
            try m.encode(to: encoder)
        }
    }
}

