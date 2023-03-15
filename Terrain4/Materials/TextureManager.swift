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
        
        // Texture was not found in the dictionary.
        // Download the texture and add it to the dictionary.
        let loader = MTKTextureLoader(device: device)

        var data: Data? = nil
        
        if !path.hasPrefix("http:") {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(path)
            
            print(url)
            
            data = try Data(contentsOf: url)
        }
        else {
            data = await Http.downloadFile(path: path, mimeType: "image/jpg")
        }

        guard let data = data else {
            throw Errors.downloadFailed
        }
        
        texture = try await loader.newTexture(data: data, options: [.generateMipmaps: true])
        
        guard let texture = texture else {
            throw Errors.invalidTexture
        }
        
        textures[path] = texture
        
        return texture
    }
    
    func addTexture(device: MTLDevice, color: Float) async throws -> MTLTexture {
        let textureName = String(color)
        
        let texture = self.textures[textureName]
        
        if let texture = texture {
            return texture
        }

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Unorm, width: 1, height: 1, mipmapped: false)
        
        if let texture = device.makeTexture(descriptor: descriptor) {
            let unsafeMutablePointer = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 0)

            unsafeMutablePointer.storeBytes(of: UInt8(0xFF * color), as: UInt8.self)

            let region = MTLRegion(origin: MTLOrigin(x:0, y: 0, z: 0), size: MTLSize(width: 1, height: 1, depth: 1))

            texture.replace(region: region, mipmapLevel: 0, withBytes: unsafeMutablePointer, bytesPerRow: 1)

            textures[textureName] = texture

            return texture
        }
        
        throw Errors.invalidTexture
    }
    
    func addTexture(device: MTLDevice, color: Vec4, pixelFormat: MTLPixelFormat) async throws -> MTLTexture {
        let textureName = "\(color[0]), \(color[1]), \(color[2]), \(color[3])"
        let texture = self.textures[textureName]
        
        if let texture = texture {
            return texture
        }

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: 1, height: 1, mipmapped: false)
        
        if let texture = device.makeTexture(descriptor: descriptor) {
            let unsafeMutablePointer = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 4)

            print(color)
            
            let b = UInt32(UInt32(color[3] * Float(0xFF)) << 24)
            let g = UInt32(UInt32(color[0] * Float(0xFF)) << 16)
            let r = UInt32(UInt32(color[1] * Float(0xFF)) << 8)
            let a = UInt32(UInt32(color[2] * Float(0xFF)))
            
            let v: UInt32 =  b | g | r | a

            print(String(format: "%x", r), String(format: "%x", g), String(format: "%x", b), String(format: "%x", a), String(format: "%x", v))
            
            unsafeMutablePointer.storeBytes(of: v, as: UInt32.self)

            let region = MTLRegion(origin: MTLOrigin(x:0, y: 0, z: 0), size: MTLSize(width: 1, height: 1, depth: 1))

            texture.replace(region: region, mipmapLevel: 0, withBytes: unsafeMutablePointer, bytesPerRow: 4)

            textures[textureName] = texture

            return texture
        }
        
        throw Errors.invalidTexture
    }
}
