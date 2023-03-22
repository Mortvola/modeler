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
    
    @Published var direction = Vec3(0, -1, 1).normalize()
    @Published var intensity = Vec3(15, 15, 15)
    @Published var shadowCaster = true
    
//    var viewMatrix = Matrix4x4()
//    var projectionMatrix = Matrix4x4()
//    var projectionViewMatrix = Matrix4x4()
    var shadowTexture: MTLTexture?
    var renderPassDescriptor: MTLRenderPassDescriptor?
    
//    var cameraFustrum: [Vec4] = []
//    var lightFustrum: [Vec4] = []
    
    func calculateProjectionViewMatrix(cameraFustrum: [Vec4]) -> Matrix4x4 {
        var center = Vec4(0, 0, 0, 0)
        for corner in cameraFustrum {
            center += corner
        }
        
        center = center.multiply(1.0 / Float(cameraFustrum.count))
        
        let up = Vec3(0.0, 1.0, 0.0)
        let position = center.vec3() - direction

        let viewMatrix = Matrix4x4.lookAt(offset: position, target: center.vec3(), up: up)
        
        var minimum = Vec3(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
        var maximum = Vec3(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)
        
        // Transform the world coordinates of the camera's fustrum into the
        // viewspace of the light and get the minimum and maximum coordinates.
        // The result will be a fustrum (in view space) that
        // encompasses the camera's fustrum.
        for corner in cameraFustrum {
            let trf = viewMatrix * corner
            
            minimum.x = min(minimum.x, trf.x)
            minimum.y = min(minimum.y, trf.y)
            minimum.z = min(minimum.z, trf.z)

            maximum.x = max(maximum.x, trf.x)
            maximum.y = max(maximum.y, trf.y)
            maximum.z = max(maximum.z, trf.z)
        }
        
//        let zMult: Float = 10.0;
//        if (minimum.z < 0)
//        {
//            minimum.z *= zMult;
//        }
//        else
//        {
//            minimum.z /= zMult;
//        }
//        if (maximum.z < 0)
//        {
//            maximum.z /= zMult;
//        }
//        else
//        {
//            maximum.z *= zMult;
//        }

//        var lf: [Vec4] = []
//
//        lf.append(Vec4(minimum.x, minimum.y, minimum.z, 1))
//        lf.append(Vec4(maximum.x, minimum.y, minimum.z, 1))
//        lf.append(Vec4(minimum.x, maximum.y, minimum.z, 1))
//        lf.append(Vec4(maximum.x, maximum.y, minimum.z, 1))
//
//        lf.append(Vec4(minimum.x, minimum.y, maximum.z, 1))
//        lf.append(Vec4(maximum.x, minimum.y, maximum.z, 1))
//        lf.append(Vec4(minimum.x, maximum.y, maximum.z, 1))
//        lf.append(Vec4(maximum.x, maximum.y, maximum.z, 1))

//        lightFustrum = []
//        let lightVMInverse = viewMatrix.inverse
//        for corner in lf {
//            lightFustrum.append(lightVMInverse * corner)
//        }
        
        let projectionMatrix = Matrix4x4
            .orthographic(left: minimum.x, right: maximum.x, top: maximum.y, bottom: minimum.y, near: minimum.z, far: maximum.z)
        
        return projectionMatrix * viewMatrix
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
        
        direction = try container.decode(Vec3.self, forKey: .direction)
        intensity = try container.decode(Vec3.self, forKey: .intensity)
        shadowCaster = try container.decode(Bool.self, forKey: .shadowCaster)
        
        let name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Directional Light"
        
        super.init(name: name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(direction, forKey: .direction)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(shadowCaster, forKey: .shadowCaster)
    }
    
    func createShadowTexture(device: MTLDevice) {
        if shadowTexture == nil {
            let shadowMapSize = 1024

            let shadowTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: shadowMapSize, height: shadowMapSize, mipmapped: false)
            shadowTextureDescriptor.storageMode = .private  
            shadowTextureDescriptor.usage = [.renderTarget, .shaderRead]
            shadowTextureDescriptor.textureType = .type2DArray
            shadowTextureDescriptor.arrayLength = 3
            
            shadowTexture = device.makeTexture(descriptor: shadowTextureDescriptor)
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
