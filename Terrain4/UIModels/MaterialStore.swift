//
//  TextureStore.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

class MaterialStore: ObservableObject {
    static let shared = MaterialStore()
    
    @Published var materials: [Material] = []
    @Published var selectedMaterial: Material?
    
    func addMaterial() {
        let material = Material()
        materials.append(material)

        self.selectedMaterial = material
    }
    
    func addTexture(url: URL) {
//        let item = textures.first { texture in
//            texture == url
//        }
//
//        if item == nil {
//            textures.append(url)
//        }
    }
}
