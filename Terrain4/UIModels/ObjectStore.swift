//
//  ObjectStore.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

enum SelectedNode: Equatable, Codable, Identifiable {
    static func == (lhs: SelectedNode, rhs: SelectedNode) -> Bool {
        switch lhs {
        case .model(let m1):
            switch rhs {
            case .model(let m2):
                return m2 == m1
            default:
                return false
            }
        case .object(let o1):
            switch rhs {
            case .object(let o2):
                return o1 == o2
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
        case .object(let o):
            return o.id
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
        case .object(let o):
            return o
        case .light(let l):
            return l
        case .directionalLight(let d):
            return d
        }
    }
    
    case model(Model)
    case object(RenderObject)
    case light(Light)
    case directionalLight(DirectionalLight)
}

class TreeNode: ObservableObject, Equatable, Identifiable {
    static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        lhs.content == rhs.content
    }
    
    var content: SelectedNode
    
    init(model: Model) {
        content = SelectedNode.model(model)
    }
    
    init(object: RenderObject) {
        content = SelectedNode.object(object)
    }
    
    init(light: Light) {
        content = SelectedNode.light(light)
    }
    
    init(directionalLight: DirectionalLight) {
        content = SelectedNode.directionalLight(directionalLight)
    }
    
    func getNearestModel() -> Model? {
        switch content {
        case .model(let m):
            return m
        case .object(let o):
            return o.model
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
            case .object(let o):
                return o.disabled
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
            case .object(let o):
                o.disabled = newValue
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
            case .object(let o):
                return o.name
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
            case .object(let o):
                o.name = newValue
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
            case .object(let o):
                return o
            case .light(let l):
                return l
            case .directionalLight(let d):
                return d
            }
        }
//        set(newValue) {
//            switch content {
//            case .model(let m):
//                m.disabled = newValue
//            case .object(let o):
//                o.disabled = newValue
//            case .light(let l):
//                l.disabled = newValue
//            case .directionalLight(let d):
//                d.disabled = newValue
//            }
//        }
    }

}

class Item: ObservableObject, Equatable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs === rhs
    }
    
    @Published var name: String
    
    init(name: String) {
        self.name = name
    }
}

class Node: Item {
    @Published var disabled = false
}

class ObjectStore: ObservableObject {
    @Published var models: [TreeNode] = []
    @Published var selectedNode: SelectedNode? = nil
    
    var lights: [Light] = []
    var directionalLight = DirectionalLight()
    
    @Published  var skybox: Skybox?
    
    enum ObjectType: String, CaseIterable {
        case sphere
        case rectangle
        case light
        
        var name: String {rawValue}
    }
    
    func selectNode(_ node: SelectedNode) {
        self.selectedNode = node
    }

//    func selectModel(_ model: Model?) {
//        if let model = model {
//            self.selectedNode = SelectedNode.model(model)
//        }
//        else {
//            self.selectedNode = nil
//        }
//    }
    
    func selectObject(_ object: RenderObject?) {
        if let object = object {
            self.selectedNode = SelectedNode.object(object)
        }
        else {
            self.selectedNode = nil
        }
    }
    
    func selectLight(_ light: Light?) {
        if let light = light {
            self.selectedNode = SelectedNode.light(light)
        }
        else {
            self.selectedNode = nil
        }
    }
    
    func selectDirectionalLight() {
        self.selectedNode = SelectedNode.directionalLight(self.directionalLight)
    }
    
    @MainActor
    func addModel() -> TreeNode {
        let treeNode = TreeNode(model: Model())
        models.append(treeNode)

        return treeNode
    }
    
    private func getModel() -> Model? {
        if let selectedNode = selectedNode {
            switch selectedNode {
            case .model(let m):
                return m;
            case .object(let o):
                return o.model;
            case .light(let l):
                return l.model
            case .directionalLight:
                return nil
            }
        }

        return nil
    }
        
    @MainActor
    func addLight() throws {
        guard let model = getModel() else {
            throw Errors.modelNotSelected
        }
        
        let light = model.addLight()
        self.lights.append(light)
        
        selectLight(light)
    }
    
    @MainActor
    func addSkybox() async throws {
        try await self.skybox = Skybox(device: Renderer.shared.device!, view: Renderer.shared.view!)
    }
}

func getDocumentsDirectory() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}
