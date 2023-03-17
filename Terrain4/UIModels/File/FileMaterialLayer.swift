//
//  MaterialLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

extension File {
    class MaterialLayer: Codable {
        var map = ""
        var useSimple = false
        
        init(layer: Terrain4.MaterialLayer) {
            self.map = layer.map
            self.useSimple = layer.useSimple
        }
    }
}
