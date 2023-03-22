//
//  MaterialManager.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import MetalKit
import Metal

class MaterialManager: ObservableObject {
    static var shared = MaterialManager()

    class MaterialEntry {
        var material: PbrMaterial
        var objects: [RenderObject] = []

        init(material: PbrMaterial) {
            self.material = material
        }
    }
    
    @Published var materials: [UUID?:MaterialEntry] = [:]
        
    func addMaterial() async throws {
        let materialDescriptor = MaterialDescriptor()
        
        materialDescriptor.name = "Material_0"
        
        _ = try await addMaterial(device: Renderer.shared.device!, view: Renderer.shared.view!, descriptor: materialDescriptor)
    }

    func addMaterial(device: MTLDevice, view: MTKView, descriptor: MaterialDescriptor?) async throws -> MaterialEntry {
        
        let materialKey = descriptor?.id
 
        if let entry = self.materials[materialKey] {
            return entry
        }

        let material = try await PbrMaterial(device: device, view: view, descriptor: descriptor)

        let entry = MaterialEntry(material: material)
        self.materials[materialKey] = entry

        return entry
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        try self.materials.forEach { key, entry in
            if entry.objects.count > 0 {
                entry.material.prepare(renderEncoder: renderEncoder)
                let pbrProperties = entry.material.getPbrProperties()
                
                for renderObject in entry.objects {
                    if !renderObject.disabled && !(renderObject.model?.disabled ?? true) {
                        try renderObject.draw(renderEncoder: renderEncoder, modelMatrix: renderObject.modelMatrix(), pbrProperties: pbrProperties, frame: frame)
                    }
                }
            }
        }
    }
}
