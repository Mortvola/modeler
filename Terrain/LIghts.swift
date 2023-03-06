//
//  LIghts.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import Foundation

class Lights: ObservableObject {
    static let shared = Lights()
    
    @Published var pointLight = true
    
    var rotation = Float(0.0)
    var position = vec3(0.0, 2.0, 0.0)
    
    @Published var red: Float = 500.0
    @Published var green: Float = 500.0
    @Published var blue: Float = 500.0
    
    @Published var rotateObject = false
    @Published var rotateLight = false
}
