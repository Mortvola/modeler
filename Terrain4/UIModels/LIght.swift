//
//  LIght.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import Foundation

class Light: Object {
    @Published var pointLight = true
    
    @Published var position = Vec3(0, 0, 0)
    @Published var intensity = Vec3(0, 0, 0)
    
    private static var lightCounter = 0
    
    override init(model: Model) {
        super.init(model: model)
        
        self.name = "Light_\(Light.lightCounter)"
        Light.lightCounter += 1
    }
}
