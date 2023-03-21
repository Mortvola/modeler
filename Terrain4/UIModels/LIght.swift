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
    
    override init(model: Model?) {
        super.init(model: model)
        
        self.name = "Light_\(Light.lightCounter)"
        Light.lightCounter += 1
    }
    
    enum CodingKeys: CodingKey {
        case position
        case intensity
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        position = try container.decode(Vec3.self, forKey: .position)
        intensity = try container.decode(Vec3.self, forKey: .intensity)
    
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(position, forKey: .position)
        try container.encode(intensity, forKey: .intensity)

        try super.encode(to: encoder)
    }
}
