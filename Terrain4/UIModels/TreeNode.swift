//
//  TreeNode.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation

class TreeNode: ObservableObject, Equatable, Identifiable, Codable {
    static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        lhs.content == rhs.content
    }
    
    var content: ObjectWrapper
    
    init(model: Model) {
        content = ObjectWrapper.model(model)
    }
    
    init(mesh: Mesh) {
        content = ObjectWrapper.mesh(mesh)
    }
    
    init(point: Point) {
        content = ObjectWrapper.point(point)
    }
    
    init(billboard: Billboard) {
        content = ObjectWrapper.billboard(billboard)
    }
    
    init(light: Light) {
        content = ObjectWrapper.light(light)
    }
    
    init(directionalLight: DirectionalLight) {
        content = ObjectWrapper.directionalLight(directionalLight)
    }
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    required init(from decoder: Decoder) throws {
        content = try ObjectWrapper(from: decoder)
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

