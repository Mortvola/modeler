//
//  Terrain.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import MetalKit
import Metal

class PbrMaterial: Item, BaseMaterial, Hashable {
    static func == (lhs: PbrMaterial, rhs: PbrMaterial) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id = UUID()

    var albedo = AlbedoLayer()
    var normals = NormalsLayer()
    var metallic = MetallicLayer()
    var roughness = RoughnessLayer()
    var ao: MTLTexture?
    
    var textures: [MTLTexture?] = []

    var objects: [RenderObject] = []

    func setSimpleMetallic(_ value: Float) {
        self.metallic.value = value
    }

    func setSimpleRoughness(_ value: Float) {
        self.roughness.value = value
    }
    
    func setSimpleAlbedo(_ color: Vec4) {
        self.albedo.color = color
    }
    
    init(device: MTLDevice, view: MTKView, descriptor: MaterialDescriptor?) async throws {
        self.id = descriptor?.id ?? UUID()
        
        // Albedo
        self.albedo.useSimple = descriptor?.albedo.useSimple ?? false
        self.albedo.color = descriptor?.albedo.color ?? Vec4(1.0, 1.0, 1.0, 1.0)
        self.albedo.map = descriptor?.albedo.map ?? ""
        
        if self.albedo.map.isEmpty {
            self.textures.append(try? await TextureManager.shared.addTexture(device: device, path: self.albedo.map))
        }
        else {
            self.textures.append(nil)
        }
        
        // Normals
        self.normals.useSimple = descriptor?.normals.useSimple ?? false
        self.normals.normal = (Vec4(0.0, 0.0, 1.0, 1.0)
            .add(1.0)
            .multiply(0.5))
        self.normals.map = descriptor?.normals.map ?? ""

        if !self.normals.map.isEmpty {
            self.textures.append(try? await TextureManager.shared.addTexture(device: device, path: self.normals.map))
        }
        else {
            self.textures.append(nil)
        }

        // Metalness
        self.metallic.useSimple = descriptor?.metallic.useSimple ?? false
        self.metallic.value = descriptor?.metallic.value ?? 1.0
        self.metallic.map = descriptor?.metallic.map ?? ""

        if !self.metallic.map.isEmpty {
            self.textures.append(try? await TextureManager.shared.addTexture(device: device, path: self.metallic.map))
        }
        else {
            self.textures.append(nil)
        }

        // Roughness
        self.roughness.useSimple = descriptor?.roughness.useSimple ?? false
        self.roughness.value = descriptor?.roughness.value ?? 1.0
        self.roughness.map = descriptor?.roughness.map ?? ""

        if !self.roughness.map.isEmpty {
            self.textures.append(try? await TextureManager.shared.addTexture(device: device, path: self.roughness.map))
        }
        else {
            self.textures.append(nil)
        }

        self.ao = nil
        
        super.init(name: descriptor?.name ?? "")
    }
    
    func getPbrProperties() -> PbrProperties? {
        let p  = Float(2.2)
        let r = pow(albedo.color.x, p)
        let g = pow(albedo.color.y, p)
        let b = pow(albedo.color.z, p)
        
        let color = Vec3(r, g, b)
        
        return PbrProperties(albedo: color, normal: self.normals.normal.vec3(), metallic: self.metallic.value, roughness: self.roughness.value)
    }
    
    func prepare(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setFragmentTextures(self.textures, range: 0..<textures.count)
    }
}

struct PbrProperties {
    var albedo: Vec3
    var normal: Vec3
    var metallic: Float
    var roughness: Float
}
