//
//  MaterialManager.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import MetalKit
import Metal

class MaterialManager {
    static var shared = MaterialManager()

    enum MaterialName {
        case terrain
        case line
        case pbrLine
    }

    class MaterialEntry {
        var material: BaseMaterial
        var objects: [RenderObject] = []

        init(material: BaseMaterial) {
            self.material = material
        }
    }
    
    struct MaterialKey: Hashable {
        var albedo: String?
        var normals: String?
        var metalness: String?
        var roughness: String?
    }

    var materials: [MaterialKey:MaterialEntry] = [:]
    
//    func addMaterial(device: MTLDevice, view: MTKView, name: MaterialName) async throws -> MaterialEntry {
//        if let entry = self.materials[name] {
//            return entry
//        }
//
//        var material: BaseMaterial?
//
//        switch (name) {
//        case .terrain:
//            material = try await TerrainMaterial(device: device, view: view)
//            break;
//
//        case .line:
//            material = try LineMaterial(device: device, view: view)
//            break;
//
//        case .pbrLine:
//            material = try await PbrLineMaterial(device: device, view: view)
//            break;
//        }
//
//        guard let material = material else {
//            throw Errors.invalidMaterial
//        }
//
//        let entry = MaterialEntry(material: material)
//        self.materials[name] = entry
//
//        return entry
//    }
    
    func addMaterial(device: MTLDevice, view: MTKView, albedo: String?, normals: String?, metalness: String?, roughness: String?) async throws -> MaterialEntry {
        
        let materialKey = MaterialKey(albedo: albedo, normals: normals, metalness: metalness, roughness: roughness)
 
        if let entry = self.materials[materialKey] {
            return entry
        }

        let material = try await TerrainMaterial(device: device, view: view, albedo: albedo, normals: normals, metalness: metalness, roughness: roughness)

        let entry = MaterialEntry(material: material)
        self.materials[materialKey] = entry

        return entry
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) throws {
        try self.materials.forEach { key, entry in
            entry.material.prepare(renderEncoder: renderEncoder)
            
            try entry.objects.forEach { object in
                try object.draw(renderEncoder: renderEncoder, modelMatrix: object.modelMatrix())
            }
        }
    }
}
