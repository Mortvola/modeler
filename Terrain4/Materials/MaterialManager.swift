//
//  MaterialManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/24/23.
//

import Foundation
import MetalKit

class MaterialManager: ObservableObject {
    @Published var materials: [UUID:MaterialWrapper] = [:]
    var defaultMaterial: MaterialWrapper
    
    init() {
        defaultMaterial = MaterialWrapper.pbrMaterial(PbrMaterial())
    }
    
    func addMaterial(pbrMaterial: PbrMaterial) {
        let entry = materials[pbrMaterial.id]
        
        if entry == nil {
            materials[pbrMaterial.id] = MaterialWrapper.pbrMaterial(pbrMaterial)
        }
    }
    
    func addMaterial(simpleMaterial: SimpleMaterial) {
        let entry = materials[simpleMaterial.id]
        
        if entry == nil {
            materials[simpleMaterial.id] = MaterialWrapper.simpleMaterial(simpleMaterial)
        }
    }
    
    func getMaterial(materialId: UUID?) -> MaterialWrapper? {
        if let materialId = materialId {
            return materials[materialId]
        }
        
        return defaultMaterial
    }
    
    func setMaterial(object: RenderObject, materialId: UUID?) {
        if let materialId = materialId {
            let materialWrapper = materials[materialId]

            setMaterial(object: object, material: materialWrapper)
        }
        else {
            setMaterial(object: object, material: defaultMaterial)
        }
    }

    func setMaterial(object: RenderObject, material: MaterialWrapper?) {
        if material != object.material {
            if let oldMaterial = object.material {
                oldMaterial.material.removeObject(object: object)
            }
            else {
                defaultMaterial.material.removeObject(object: object)
            }
            
            if let material = material {
                material.material.addObject(object: object)
                object.material = material
            }
            else {
                defaultMaterial.material.addObject(object: object)
                object.material = defaultMaterial
            }
        }
    }
}
