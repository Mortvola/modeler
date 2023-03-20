//
//  DirectionalLight.swift
//  Terrain4
//
//  Created by Richard Shields on 3/18/23.
//

import Foundation
import Metal

class DirectionalLight: Node, Equatable, Codable {
    static func == (lhs: DirectionalLight, rhs: DirectionalLight) -> Bool {
        lhs === rhs
    }
    
    @Published var enabled = false
    @Published var direction = Vec3(0, -1, 1).normalize()
    @Published var intensity = Vec3(15, 15, 15)
    @Published var shadowCaster = true
    
    var shadowTexture: MTLTexture?
    
    func getViewMatrix() -> Matrix4x4 {
        let position = -direction * 75
        let target = Vec3(0, 0, 0)
        let up = Vec3(0.0, 1.0, 0.0)
        
        return Matrix4x4.lookAt(offset: position, target: target, up: up)
    }
    
    func getProjectionViewMatrix() -> Matrix4x4 {
        Matrix4x4
            .orthographic(left: -30, right: 30, top: 30, bottom: -30, near: 0, far: 100)
            .multiply(self.getViewMatrix())
    }
    
    enum CodingKeys: CodingKey {
        case enabled
        case direction
        case intensity
        case shadowCaster
        case name
    }
    
    init() {
        super.init(name: "Directional Light")
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        enabled = try container.decode(Bool.self, forKey: .enabled)
        direction = try container.decode(Vec3.self, forKey: .direction)
        intensity = try container.decode(Vec3.self, forKey: .intensity)
        shadowCaster = try container.decode(Bool.self, forKey: .shadowCaster)
        
        let name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Directional Light"
        
        super.init(name: name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(direction, forKey: .direction)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(shadowCaster, forKey: .shadowCaster)
    }
    
    func createShadowTexture(device: MTLDevice) {
        let shadowMapSize = 2048
        let shadowTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: shadowMapSize, height: shadowMapSize, mipmapped: false)
        shadowTextureDescriptor.storageMode = .private
        shadowTextureDescriptor.usage = [.renderTarget, .shaderRead]
        
        shadowTexture = device.makeTexture(descriptor: shadowTextureDescriptor)
    }
}
