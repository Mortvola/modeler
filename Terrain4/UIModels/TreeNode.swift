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
        case .light(let l):
            return l
        case .directionalLight(let d):
            return d
        }
    }
    
    case model(Model)
    case mesh(Mesh)
    case point(Point)
    case light(Light)
    case directionalLight(DirectionalLight)
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
    
    init(light: Light) {
        content = NodeContent.light(light)
    }
    
    init(directionalLight: DirectionalLight) {
        content = NodeContent.directionalLight(directionalLight)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            let model = try container.decode(Model.self)
            
            self.content = NodeContent.model(model)
            
            return
        }
        catch {}
        
        do {
            let mesh = try container.decode(Mesh.self)
            
            self.content = NodeContent.mesh(mesh)
            
            return
        }
        catch {}
        
        do {
            let point = try container.decode(Point.self)
            
            self.content = NodeContent.point(point)
            
            return
        }
        catch {}
        
        do {
            let light = try container.decode(Light.self)
            
            self.content = NodeContent.light(light)
            
            return
        }
        catch {}
        
        do {
            let directedLight = try container.decode(DirectionalLight.self)
            
            self.content = NodeContent.directionalLight(directedLight)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch content {
        case .model(let m):
            try container.encode(m)
        case .mesh(let o):
            try container.encode(o)
        case .point(let p):
            try container.encode(p)
        case .light(let l):
            try container.encode(l)
        case .directionalLight(let d):
            try container.encode(d)
        }
    }
    
    func getNearestModel() -> Model? {
        switch content {
        case .model(let m):
            return m
        case .mesh(let o):
            return o.model
        case .point(let p):
            return p.model
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
            case .light(let l):
                return l
            case .directionalLight(let d):
                return d
            }
        }
    }
}

