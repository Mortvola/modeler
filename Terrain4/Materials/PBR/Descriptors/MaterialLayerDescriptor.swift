//
//  MaterialLayerDescriptor.swift
//  Terrain4
//
//  Created by Richard Shields on 3/17/23.
//

import Foundation

class MaterialLayerDescriptor: Codable {
    var map: String
    var useSimple: Bool
    
    init() {
        self.map = ""
        self.useSimple = false
    }
    
    init(materialLayer: MaterialLayer) {
        self.map = materialLayer.map
        self.useSimple = materialLayer.useSimple
    }
}
