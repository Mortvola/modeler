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
    }

    class MaterialEntry {
        var material: Material
        var objects: [RenderObject] = []

        init(material: Material) {
            self.material = material
        }
    }

    var materials: [MaterialName:MaterialEntry] = [:]
    
    func addMaterial(device: MTLDevice, view: MTKView, name: MaterialName) throws -> MaterialEntry {
        if let entry = self.materials[name] {
            return entry
        }
        
        var material: Material?
        
        switch (name) {
        case .terrain:
            material = try TerrainMaterial(device: device, view: view)
            break;
            
        case .line:
            material = try LineMaterial(device: device, view: view)
            break;
        }
        
        guard let material = material else {
            throw Errors.invalidMaterial
        }
        
        let entry = MaterialEntry(material: material)
        self.materials[name] = entry

        return entry
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        self.materials.forEach { key, entry in
            renderEncoder.setRenderPipelineState(entry.material.getPipeline())
            
            entry.objects.forEach { object in
                object.draw(renderEncoder: renderEncoder, modelMatrix: object.modelMatrix())
            }
        }
    }
}
