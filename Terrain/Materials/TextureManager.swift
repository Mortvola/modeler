//
//  TextureManager.swift
//  Terrain
//
//  Created by Richard Shields on 2/28/23.
//

import Foundation
import Metal
import MetalKit
import Http

class TextureManager {
    static var shared = TextureManager()

    var textures: [String:MTLTexture] = [:]
    
    func addTexture(device: MTLDevice, path: String) async throws -> MTLTexture {
        var texture = self.textures[path]
        
        if let texture = texture {
            return texture
        }

        let loader = MTKTextureLoader(device: device)
            
        guard let data = await Http.downloadFile(path: path, mimeType: "image/jpg") else {
            throw Errors.downloadFailed
        }

        texture = try await loader.newTexture(data: data, options: [.generateMipmaps: true])
        
        guard let texture = texture else {
            throw Errors.invalidTexture
        }
        
        return texture
    }
}
