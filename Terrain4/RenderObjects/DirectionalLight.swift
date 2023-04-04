//
//  DirectionalLight.swift
//  Terrain4
//
//  Created by Richard Shields on 3/18/23.
//

import Foundation
import Metal

let shadowMapCascades = 4

class DirectionalLight: Node {
    static func == (lhs: DirectionalLight, rhs: DirectionalLight) -> Bool {
        lhs === rhs
    }
    
    let id: UUID
    
    @Published var direction = Vec3(0, -1, 1).normalize()
    @Published var intensity = Vec3(15, 15, 15)
    @Published var shadowCaster = true
    
    let shadowMapSize = 1024

    var shadowTexture: MTLTexture?
    var renderPassDescriptor: MTLRenderPassDescriptor?
    
    var prevExtents = Vec3()

    func calculateProjectionViewMatrix(cameraFrustum corners: [Vec4]) -> Matrix4x4 {
        var center = Vec4(0, 0, 0, 0)
        for corner in corners {
            center += corner
        }
        
        center /= Float(corners.count)
        
        // Find bounding sphere around frustum
        var sphereRadius = Float(0.0)
        for corner in corners {
            let length = length(corner - center)
            sphereRadius = max(sphereRadius, length)
        }
        
        // Truncate the radius to a multiple of 0.5. This will
        // ensure the dimensions of the mapped area to be in integer
        // units (the dimensions of the mapped area will have dimensions
        // of sphereRadius * 2)
        sphereRadius = ceil(sphereRadius * 2.0) / 2.0
        
        // Create a transormation matrix to tansform the frustum center
        // to the light space origin
        let up = Vec3(0.0, 1.0, 0.0)
        let target = center.vec3() + direction
        let viewMatrix = Matrix4x4.lookAt(offset: center.vec3(), target: target, up: up)
                
        // Create a projection matrix using the bounds of the sphere.
        var projectionMatrix = Matrix4x4
            .orthographic(left: -sphereRadius, right: sphereRadius, top: sphereRadius, bottom: -sphereRadius, near: -sphereRadius, far: sphereRadius)

        let viewProjectionMatrix = projectionMatrix * viewMatrix
        
        // Transform the world origin into the light's NDC space
        // to determine how much of an offset needs to be applied to
        // align on texture units.
        var origin = viewProjectionMatrix * Vec4(0, 0, 0, 1)
        origin *= Float(shadowMapSize) / 2.0 // Convert NDC into texture space
        let roundedOrigin = round(origin)
        var offset = roundedOrigin - origin
        offset *= 2 / Float(shadowMapSize) // Convert texture space back into NDC

        projectionMatrix[3][0] = offset.x
        projectionMatrix[3][1] = offset.y
        
        return projectionMatrix * viewMatrix
    }

    enum CodingKeys: CodingKey {
        case id
        case enabled
        case direction
        case intensity
        case shadowCaster
    }
    
    init() {
        self.id = UUID()

        super.init(name: "Directional Light")
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        direction = try container.decode(Vec3.self, forKey: .direction)
        intensity = try container.decode(Vec3.self, forKey: .intensity)
        shadowCaster = try container.decode(Bool.self, forKey: .shadowCaster)

        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(direction, forKey: .direction)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(shadowCaster, forKey: .shadowCaster)
        
        try super.encode(to: encoder)
    }
    
    func createShadowTexture() {
        if shadowTexture == nil {
            let shadowTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: shadowMapSize, height: shadowMapSize, mipmapped: false)
            shadowTextureDescriptor.storageMode = .private  
            shadowTextureDescriptor.usage = [.renderTarget, .shaderRead]
            shadowTextureDescriptor.textureType = .type2DArray
            shadowTextureDescriptor.arrayLength = shadowMapCascades
            
            shadowTexture = MetalView.shared.device.makeTexture(descriptor: shadowTextureDescriptor)
            shadowTexture?.label = "Shadow Map"
            
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.depthAttachment.loadAction = .clear
            renderPassDescriptor.depthAttachment.storeAction = .store
            renderPassDescriptor.depthAttachment.clearDepth = 1.0
            renderPassDescriptor.depthAttachment.texture = self.shadowTexture!
                
            self.renderPassDescriptor = renderPassDescriptor
        }
    }
}
