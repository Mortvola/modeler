//
//  Pipeline.swift
//  Terrain4
//
//  Created by Richard Shields on 3/25/23.
//

import Foundation

class Pipeline {
    var materials: [UUID?:MaterialWrapper] = [:]
    
    init() throws {}
    
    func addMaterial(material: MaterialWrapper) {
        let materialKey = material.id
        
        if materials[materialKey] == nil {
            materials[materialKey] = material
        }
    }
    
    func clearDrawables() {
        for material in materials {
            material.value.material.clearDrawables()
        }
    }
}
