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

//    enum MaterialName {
//        case terrain
//        case line
//        case pbrLine
//    }
//
    class MaterialEntry {
        var material: PbrMaterial
        var objects: [RenderObject] = []

        init(material: PbrMaterial) {
            self.material = material
        }
    }
    
    var materials: [Material?:MaterialEntry] = [:]
        
    func addMaterial(device: MTLDevice, view: MTKView, material: Material?) async throws -> MaterialEntry {
        
        let materialKey = material
 
        if let entry = self.materials[materialKey] {
            return entry
        }

        let material = try await PbrMaterial(device: device, view: view, material: material)

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
