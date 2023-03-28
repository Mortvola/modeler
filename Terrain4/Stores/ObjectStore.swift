//
//  ObjectStore.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

class ObjectStore: ObservableObject {
    var loaded = false
    
    @Published var models: [TreeNode] = []
    let modelingScene = TheScene()
    let scene = TheScene()
    
    var currentScene: TheScene? = nil
    
    var directionalLight = DirectionalLight()
    
    var animators: [Animator] = []
    
    @Published  var skybox: Skybox?
    
    init() {
        modelingScene.directionalLight = directionalLight
        currentScene = modelingScene
    }
    
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
