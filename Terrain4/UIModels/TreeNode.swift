//
//  TreeNode.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation

enum NodeContent: Equatable, Codable, Identifiable {
    static func == (lhs: NodeContent, rhs: NodeContent) -> Bool {
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
            self = NodeContent.model(model)
            return
        case "Mesh":
            let mesh = try Mesh(from: decoder)
            self = NodeContent.mesh(mesh)
            return
        case "Point":
            let point = try Point(from: decoder)
            self = NodeContent.point(point)
            return
        case "Billboard":
            let billboard = try Billboard(from: decoder)
            self = NodeContent.billboard(billboard)
            return
        case "Light":
            let light = try Light(from: decoder)
            self = NodeContent.light(light)
            return
        case "DirectionalLight":
            let directionalLight = try DirectionalLight(from: decoder)
            self = NodeContent.directionalLight(directionalLight)
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

class TreeNode: ObservableObject, Equatable, Identifiable, Codable {
    static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        lhs.content == rhs.content
    }
    
    var content: NodeContent
    
    init(model: Model) {
        content = NodeContent.model(model)
    }
    
    init(mesh: Mesh) {
        content = NodeContent.mesh(mesh)
    }
    
    init(point: Point) {
        content = NodeContent.point(point)
    }
    
    init(billboard: Billboard) {
        content = NodeContent.billboard(billboard)
    }
    
    init(light: Light) {
        content = NodeContent.light(light)
    }
    
    init(directionalLight: DirectionalLight) {
        content = NodeContent.directionalLight(directionalLight)
    }
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    required init(from decoder: Decoder) throws {
        content = try NodeContent(from: decoder)
    }
    
    func encode(to encoder: Encoder) throws {
        try content.encode(to: encoder)
    }
    
    func getNearestModel() -> Model? {
        switch content {
        case .model(let m):
            return m
        case .mesh(let o):
            return o.model
        case .point(let p):
            return p.model
        case .billboard(let b):
            return b.model
        case .light(let l):
            return l.model
        case .directionalLight:
            return nil
        }
    }
    
    var disabled: Bool {
        get {
            switch content {
            case .model(let m):
                return m.disabled
            case .mesh(let o):
                return o.disabled
            case .point(let p):
                return p.disabled
            case .billboard(let b):
                return b.disabled
            case .light(let l):
                return l.disabled
            case .directionalLight(let d):
                return d.disabled
            }
        }
        set(newValue) {
            switch content {
            case .model(let m):
                m.disabled = newValue
            case .mesh(let o):
                o.disabled = newValue
            case .point(let p):
                p.disabled = newValue
            case .billboard(let b):
                b.disabled = newValue
            case .light(let l):
                l.disabled = newValue
            case .directionalLight(let d):
                d.disabled = newValue
            }
        }
    }

    var name: String {
        get {
            switch content {
            case .model(let m):
                return m.name
            case .mesh(let o):
                return o.name
            case .point(let p):
                return p.name
            case .billboard(let b):
                return b.name
            case .light(let l):
                return l.name
            case .directionalLight(let d):
                return d.name
            }
        }
        set(newValue) {
            switch content {
            case .model(let m):
                m.name = newValue
            case .mesh(let o):
                o.name = newValue
            case .point(let p):
                p.name = newValue
            case .billboard(let b):
                b.name = newValue
            case .light(let l):
                l.name = newValue
            case .directionalLight(let d):
                d.name = newValue
            }
        }
    }

    var item: Item {
        get {
            switch content {
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
    }
}

