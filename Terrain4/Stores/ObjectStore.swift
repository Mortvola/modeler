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
    func deleteModel(model: Model) {
        let index = models.firstIndex {
            switch $0.content {
            case .model(let m):
                return m == model
            default:
                return false
            }
        }
        
        if let index = index {
            models.remove(at: index)
        }
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

func getTexturesDirectory() -> URL {
    getDocumentsDirectory().appendingPathComponent("textures")
}

func getModelsDirectory() -> URL {
    getDocumentsDirectory().appendingPathComponent("models")
}

func makeModelsDirectory() {
    let url = getModelsDirectory()
    
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
}
