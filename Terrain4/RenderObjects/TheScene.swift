//
//  Scene.swift
//  Terrain4
//
//  Created by Richard Shields on 3/27/23.
//

import Foundation

class TheScene: ObservableObject {
    @Published var models: [SceneModel] = []
    
    var lights: [Light] = []

    var directionalLight: DirectionalLight?
    
    var frustum: Model? = nil
}
