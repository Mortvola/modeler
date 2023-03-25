//
//  SimpleMaterial.swift
//  Terrain4
//
//  Created by Richard Shields on 3/24/23.
//

import Foundation
import Metal
import MetalKit


class SimpleMaterial: Material {
    var layers: [LayerContent] = []

    init() {
        self.layers.append(LayerContent.color(Vec4(1, 1, 1, 1)))
        
        super.init(name: "Simple Material")
    }

//    init(device: MTLDevice, view: MTKView, descriptor: MaterialDescriptor?) async throws {
//        super.init(name: "Simple Material")
//    }

    override func prepare(renderEncoder: MTLRenderCommandEncoder) {
    }
    
    enum CodingKeys: CodingKey {
        case layers
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        layers = try container.decode([LayerContent].self, forKey: .layers)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(layers, forKey: .layers)
        
        try super.encode(to: encoder)
    }
}
