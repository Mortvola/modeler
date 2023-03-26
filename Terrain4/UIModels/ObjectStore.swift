//
//  ObjectStore.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

class Item: ObservableObject, Equatable, Codable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs === rhs
    }
    
    @Published var name: String
    
    init(name: String) {
        self.name = name
    }
    
    enum CodingKeys: CodingKey {
        case name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
    }
}

class Node: Item {
    @Published var disabled = false
}

class ObjectStore: ObservableObject {
    @Published var models: [TreeNode] = []
    
    var lights: [Light] = []
    var directionalLight = DirectionalLight()
    
    @Published  var skybox: Skybox?
    
    @MainActor
    func addModel() -> TreeNode {
        let treeNode = TreeNode(model: Model())
        models.append(treeNode)

        return treeNode
    }
    
    @MainActor
    func addSkybox() async throws {
        try await self.skybox = Skybox()
    }
}

func getDocumentsDirectory() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}
