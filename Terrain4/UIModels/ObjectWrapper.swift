//
//  ObjectWrapper.swift
//  Terrain4
//
//  Created by Richard Shields on 3/25/23.
//

import Foundation

enum ObjectWrapper: Equatable, Codable, Identifiable {
    static func == (lhs: ObjectWrapper, rhs: ObjectWrapper) -> Bool {
        switch lhs {
        case .model(let m1):
            switch rhs {
            case .model(let m2):
                return m2 == m1
            default:
                return false
            }
        case .mesh(let o1):
            switch rhs {
            case .mesh(let o2):
                return o1 == o2
            default:
                return false
            }
        case .point(let p1):
            switch rhs {
            case .point(let p2):
                return p1 == p2
            default:
                return false
            }
        case .billboard(let b1):
            switch rhs {
            case .billboard(let b2):
                return b1 == b2
            default:
                return false
            }
        case .light(let l1):
            switch rhs {
            case .light(let l2):
                return l1 == l2
            default:
                return false
            }
        case .directionalLight(let d1):
            switch rhs {
            case .directionalLight(let d2):
                return d1 == d2
            default:
                return false
            }
        }
    }
    
    var id: UUID {
        switch(self) {
        case .model(let m):
            return m.id
        case .mesh(let o):
            return o.id
        case .point(let p):
            return p.id
        case .billboard(let b):
            return b.id
        case .light(let l):
            return l.id
        case .directionalLight(let d):
            return d.id
        }
    }
    
    var item: Node {
        switch(self) {
        case .model(let m):
            return m
        case .mesh(let o):
            return o
        case .point(let p):
            return p
        case .billboard(let b):
            return b
        case .light(let l):
            return l
        case .directionalLight(let d):
            return d
        }
    }
    
    case model(Model)
    case mesh(Mesh)
    case point(Point)
    case billboard(Billboard)
    case light(Light)
    case directionalLight(DirectionalLight)
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "Model":
            let model = try Model(from: decoder)
            self = ObjectWrapper.model(model)
            return
        case "Mesh":
            let mesh = try Mesh(from: decoder)
            self = ObjectWrapper.mesh(mesh)
            return
        case "Point":
            let point = try Point(from: decoder)
            self = ObjectWrapper.point(point)
            return
        case "Billboard":
            let billboard = try Billboard(from: decoder)
            self = ObjectWrapper.billboard(billboard)
            return
        case "Light":
            let light = try Light(from: decoder)
            self = ObjectWrapper.light(light)
            return
        case "DirectionalLight":
            let directionalLight = try DirectionalLight(from: decoder)
            self = ObjectWrapper.directionalLight(directionalLight)
            return
        default:
            break
        }
        
        throw Errors.invalidObject
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch(self) {
        case .model(let m):
            try container.encode("Model", forKey: .type)
            try m.encode(to: encoder)
        case .mesh(let o):
            try container.encode("Mesh", forKey: .type)
            try o.encode(to: encoder)
        case .point(let p):
            try container.encode("Point", forKey: .type)
            try p.encode(to: encoder)
        case .billboard(let b):
            try container.encode("Billboard", forKey: .type)
            try b.encode(to: encoder)
        case .light(let l):
            try container.encode("Light", forKey: .type)
            try l.encode(to: encoder)
        case .directionalLight(let d):
            try container.encode("DirectionalLight", forKey: .type)
            try d.encode(to: encoder)
        }
    }
}

