//
//  MaterialLayer.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation
import Metal

class MaterialLayer {
    var map = ""
    var mapTexture: MTLTexture? = nil
    var simpleTexture: MTLTexture? = nil
    var useSimple = false
    
    func currentTexture() -> MTLTexture? {
        if let map = self.mapTexture, !self.useSimple {
            return map
        }
        
        return self.simpleTexture
    }
}
