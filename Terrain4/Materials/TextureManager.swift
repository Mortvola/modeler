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
    
    func addTexture(device: MTLDevice, color: Float) throws -> MTLTexture {
        let textureName = String(color)
        var texture = self.textures[textureName]
        
        if let texture = texture {
            return texture
        }

        texture = try createTexture(device: device, color: color)

        textures[textureName] = texture

        return texture!
    }
    
    func createTexture(device: MTLDevice, color: Float) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Unorm, width: 1, height: 1, mipmapped: false)
        
        if let texture = device.makeTexture(descriptor: descriptor) {
            TextureManager.setTextureValue(texture: texture, value: color)
            return texture
        }
        
        throw Errors.invalidTexture
    }
    
    static func setTextureValue(texture: MTLTexture, value: Float) {
        let unsafeMutablePointer = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 0)

        unsafeMutablePointer.storeBytes(of: UInt8(0xFF * max(min(value, 1.0), 0.0)), as: UInt8.self)

        let region = MTLRegion(origin: MTLOrigin(x:0, y: 0, z: 0), size: MTLSize(width: 1, height: 1, depth: 1))

        texture.replace(region: region, mipmapLevel: 0, withBytes: unsafeMutablePointer, bytesPerRow: 1)
    }
    
    static func setTextureValue(texture: MTLTexture, color: Vec4) {
        let unsafeMutablePointer = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 4)

        let b = UInt32(UInt32(color[3] * Float(0xFF)) << 24)
        let g = UInt32(UInt32(color[0] * Float(0xFF)) << 16)
        let r = UInt32(UInt32(color[1] * Float(0xFF)) << 8)
        let a = UInt32(UInt32(color[2] * Float(0xFF)))
        
        let v: UInt32 =  b | g | r | a

        unsafeMutablePointer.storeBytes(of: v, as: UInt32.self)

        let region = MTLRegion(origin: MTLOrigin(x:0, y: 0, z: 0), size: MTLSize(width: 1, height: 1, depth: 1))

        texture.replace(region: region, mipmapLevel: 0, withBytes: unsafeMutablePointer, bytesPerRow: 4)
    }
    
    func addTexture(device: MTLDevice, color: Vec4, pixelFormat: MTLPixelFormat) throws -> MTLTexture {
        let textureName = "\(color[0]), \(color[1]), \(color[2]), \(color[3])"
        var texture = self.textures[textureName]
        
        if let texture = texture {
            return texture
        }

        texture = try createTexture(device: device, color: color, pixelFormat: pixelFormat)

        textures[textureName] = texture

        return texture!
    }
    
    func createTexture(device: MTLDevice, color: Vec4, pixelFormat: MTLPixelFormat) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: 1, height: 1, mipmapped: false)
        
        if let texture = device.makeTexture(descriptor: descriptor) {
            TextureManager.setTextureValue(texture: texture, color: color)
            return texture
        }
        
        throw Errors.invalidTexture
    }
}
