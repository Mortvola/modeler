//
//  TextureStore.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import MetalKit

class TextureStore {
    var texture: MTLTexture?
    
    init(device: MTLDevice) throws {
        let loader = MTKTextureLoader(device: device)
        
        let url = getDocumentsDirectory().appendingPathComponent("/textures/fairy.png")
        let data = try Data(contentsOf: url)

        Task {
            do {
                self.texture = try await loader.newTexture(data: data, options: [:])
            }
            catch {
                print(error)
            }
        }
    }
}
