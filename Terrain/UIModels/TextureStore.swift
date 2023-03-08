//
//  TextureStore.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation

class TextureStore {
    static let shared = TextureStore()
    
    var textures: [URL] = []
    
    func addTexture(url: URL) {
        let item = textures.first { texture in
            texture == url
        }
        
        if item == nil {
            textures.append(url)
        }
    }
}
