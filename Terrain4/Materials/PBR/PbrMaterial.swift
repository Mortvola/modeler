//
//  Terrain.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import MetalKit
import Metal

class PbrMaterial: Material, Hashable {
    static func == (lhs: PbrMaterial, rhs: PbrMaterial) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var albedo = AlbedoLayer()
    var normals = NormalsLayer()
    var metallic = MetallicLayer()
    var roughness = RoughnessLayer()
    var ao: MTLTexture?
    
    var uniforms: MTLBuffer?

    var textures: [MTLTexture?] = [nil, nil, nil, nil]
    
    init() {
        super.init(name: "PBR Material")
        allocateUniforms()
    }
    
    enum CodingKeys: CodingKey {
        case albedo
        case normals
        case metallic
        case roughness
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        albedo = try container.decode(AlbedoLayer.self, forKey: .albedo)
        normals = try container.decode(NormalsLayer.self, forKey: .normals)
        metallic = try container.decode(MetallicLayer.self, forKey: .metallic)
        roughness = try container.decode(RoughnessLayer.self, forKey: .roughness)

        allocateUniforms()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(albedo, forKey: .albedo)
        try container.encode(normals, forKey: .normals)
        try container.encode(metallic, forKey: .metallic)
        try container.encode(roughness, forKey: .roughness)
        
        try super.encode(to: encoder)
    }
    
    func getPbrProperties() -> PbrProperties? {
        let p  = Float(2.2)
        let r = pow(albedo.color.x, p)
        let g = pow(albedo.color.y, p)
        let b = pow(albedo.color.z, p)
        
        let color = Vec3(r, g, b)
        
        return PbrProperties(albedo: color, normal: self.normals.normal.vec3(), metallic: self.metallic.value, roughness: self.roughness.value)
    }
    
    override func prepare(renderEncoder: MTLRenderCommandEncoder, frame: Int) {
        let u: UnsafeMutablePointer<PbrMaterialUniforms> = getUniformsBuffer(index: frame)

        let pbrProperties = getPbrProperties()
        
        u[0].albedo = pbrProperties?.albedo ?? Vec3(1.0, 1.0, 1.0)
        u[0].normals = pbrProperties?.normal ?? Vec3(0.5, 0.5, 1.0)
        u[0].metallic = pbrProperties?.metallic ?? 1.0
        u[0].roughness = pbrProperties?.roughness ?? 1.0

        renderEncoder.setFragmentBuffer(uniforms, offset: frame * MemoryLayout<PbrMaterialUniforms>.stride, index: BufferIndex.materialUniforms.rawValue)

        textures[0] = albedo.useSimple ? nil : albedo.texture
        textures[1] = normals.useSimple ? nil : normals.texture
        textures[2] = metallic.useSimple ? nil: metallic.texture
        textures[3] = roughness.useSimple ? nil :roughness.texture
        
        renderEncoder.setFragmentTextures(self.textures, range: 0..<textures.count)
    }
    
    func allocateUniforms() {
        uniforms = MetalView.shared.device!.makeBuffer(length: 3 * MemoryLayout<PbrMaterialUniforms>.stride, options: [MTLResourceOptions.storageModeShared])!
        uniforms!.label = "Material Uniforms"
    }
    
    func getUniformsBuffer(index: Int) -> UnsafeMutablePointer<PbrMaterialUniforms> {
        UnsafeMutableRawPointer(self.uniforms!.contents())
            .advanced(by: index * MemoryLayout<PbrMaterialUniforms>.stride)
            .bindMemory(to: PbrMaterialUniforms.self, capacity: 1)
    }
}

struct PbrProperties {
    var albedo: Vec3
    var normal: Vec3
    var metallic: Float
    var roughness: Float
}
