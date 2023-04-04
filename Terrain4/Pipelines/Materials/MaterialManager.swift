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
    var defaultLineMaterial: MaterialWrapper
    
    enum DefaultMaterialType {
        case mesh
        case line
    }

    init() {
        defaultMaterial = MaterialWrapper.pbrMaterial(PbrMaterial())
        defaultLineMaterial = MaterialWrapper.lineMaterial(LineMaterial())
    }
    
    private func wrapMaterial(_ material: Material) throws -> MaterialWrapper {
        if type(of: material) == PbrMaterial.self {
            return MaterialWrapper.pbrMaterial(material as! PbrMaterial)
        }
        
        if type(of: material) == GraphMaterial.self {
            return MaterialWrapper.graphMaterial(material as! GraphMaterial)
        }

        if type(of: material) == BillboardMaterial.self {
            return MaterialWrapper.billboardMaterial(material as! BillboardMaterial)
        }
        
        throw Errors.invalidMaterial
    }
    
    func addMaterial(_ material: Material) {
        if let wrappedMaterial = try? wrapMaterial(material) {
            let entry = materials[wrappedMaterial.id]
            
            if entry == nil {
                materials[wrappedMaterial.id] = wrappedMaterial
            }
        }
    }
    
    func deleteMaterial(_ materialWrapper: MaterialWrapper) {
        materials.removeValue(forKey: materialWrapper.id)
    }
    
//    func addMaterial(_ material: PbrMaterial) {
//        
//        addMaterial()
//    }
//    
//    func addMaterial(_ material: GraphMaterial) {
//        let entry = materials[material.id]
//        
//        wrapMaterial(material)
//
//        if entry == nil {
//            materials[material.id] = MaterialWrapper.graphMaterial(material)
//        }
//    }
//
//    func addMaterial(_ material: BillboardMaterial) {
//        let entry = materials[material.id]
//        
//        if entry == nil {
//            materials[material.id] = MaterialWrapper.billboardMaterial(material)
//        }
//    }

    func getMaterial(materialId: UUID?) -> MaterialWrapper? {
        if let materialId = materialId {
            return materials[materialId]
        }
        
        return defaultMaterial
    }
    
    func setMaterial(object: RenderObject, materialType: DefaultMaterialType) throws {
        switch materialType {
        case .line:
            try setMaterial(object: object, material: defaultLineMaterial)
        case .mesh:
            try setMaterial(object: object, material: defaultMaterial)
        }
    }
    
    func setMaterial(object: RenderObject, materialId: UUID?) throws {
        if let materialId = materialId {
            let materialWrapper = materials[materialId]

            try setMaterial(object: object, material: materialWrapper)
        }
        else {
            try setMaterial(object: object, material: defaultMaterial)
        }
    }

    func setMaterial(object: RenderObject, material: MaterialWrapper?) throws {
        if material != object.material || (material == nil && object.material != defaultMaterial) {
            if let oldMaterial = object.material {
                oldMaterial.material.removeObject(object: object)
            }
            else {
                defaultMaterial.material.removeObject(object: object)
            }
            
            if let material = material {
                object.material = material
                try material.material.addObject(object: object)
            }
            else {
                object.material = defaultMaterial
                try defaultMaterial.material.addObject(object: object)
            }
        }
    }
}
