//
//  Skybox.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import Metal
import MetalKit
import Http

class Skybox {
    let texture: MTLTexture
    let samplerState: MTLSamplerState
    let vertices: MTLBuffer
    var numVertices: Int = 0
    let pipeline: MTLRenderPipelineState
    let depthState: MTLDepthStencilState
    
    init() async throws {
        let vertexDescriptor = Skybox.buildVertexDescriptor()
        
        self.pipeline = try Skybox.buildPipeline(vertexDescriptor: vertexDescriptor)
        
        self.samplerState = Skybox.buildSamplerState()

        let dataSize = skyboxVertices.count * MemoryLayout.size(ofValue: skyboxVertices[0])
        self.vertices = MetalView.shared.device.makeBuffer(bytes: skyboxVertices, length: dataSize, options: [])!
        self.numVertices = skyboxVertices.count / 3
        
        let loader = MTKTextureLoader(device: MetalView.shared.device)
        
        let url = getDocumentsDirectory().appendingPathComponent("skybox-clouds.png")
        let data = try Data(contentsOf: url)

        self.texture = try await loader.newTexture(data: data, options: [.cubeLayout: MTKTextureLoader.CubeLayout.vertical])
        
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.depthCompareFunction = .lessEqual
        depthStateDescriptor.isDepthWriteEnabled = true
        
        guard let state = MetalView.shared.device.makeDepthStencilState(descriptor:depthStateDescriptor) else {
            throw Errors.depthStateCreationFailed
        }

        self.depthState = state
    }
    
    private static func buildSamplerState() -> MTLSamplerState {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        return MetalView.shared.device.makeSamplerState(descriptor: samplerDescriptor)!
    }
    
    private static func buildVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = MemoryLayout<simd_float1>.stride * 3
        
        return vertexDescriptor
    }
    
    private static func buildPipeline(
        vertexDescriptor: MTLVertexDescriptor
    ) throws -> MTLRenderPipelineState {
        /// Build a render state pipeline object
        
        let library = MetalView.shared.device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "skyboxVertexShader")
        let fragmentFunction = library?.makeFunction(name: "skyboxFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "SkyboxPipeline"
        pipelineDescriptor.rasterSampleCount = MetalView.shared.view!.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = MetalView.shared.view!.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = MetalView.shared.view!.depthStencilPixelFormat

        return try MetalView.shared.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setDepthStencilState(self.depthState)
        
        renderEncoder.setRenderPipelineState(self.pipeline)

        renderEncoder.setFragmentTexture(self.texture, index: TextureIndex.color.rawValue)
        renderEncoder.setFragmentSamplerState(samplerState, index: SamplerIndex.sampler.rawValue)

        renderEncoder.setVertexBuffer(self.vertices, offset: 0, index: BufferIndex.meshPositions.rawValue)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: self.numVertices)
    }
}

private let skyboxVertices: [simd_float1] = [
    // South
  -1.0,  1.0, -1.0,
   -1.0, -1.0, -1.0,
   1.0, -1.0, -1.0,
   1.0, -1.0, -1.0,
   1.0,  1.0, -1.0,
  -1.0,  1.0, -1.0,

   // West
  -1.0, -1.0,  1.0,
   -1.0, -1.0, -1.0,
  -1.0,  1.0, -1.0,
  -1.0,  1.0, -1.0,
   -1.0,  1.0,  1.0,
  -1.0, -1.0,  1.0,

   // East
   1.0, -1.0, -1.0,
   1.0, -1.0,  1.0,
   1.0,  1.0,  1.0,
   1.0,  1.0,  1.0,
   1.0,  1.0, -1.0,
   1.0, -1.0, -1.0,

   // North
  -1.0, -1.0,  1.0,
   -1.0,  1.0,  1.0,
   1.0,  1.0,  1.0,
   1.0,  1.0,  1.0,
   1.0, -1.0,  1.0,
  -1.0, -1.0,  1.0,

   // Up
  -1.0,  1.0, -1.0,
   1.0,  1.0, -1.0,
   1.0,  1.0,  1.0,
   1.0,  1.0,  1.0,
   -1.0,  1.0,  1.0,
  -1.0,  1.0, -1.0,

   // Down
  -1.0, -1.0, -1.0,
   -1.0, -1.0,  1.0,
   1.0, -1.0, -1.0,
   1.0, -1.0, -1.0,
   -1.0, -1.0,  1.0,
   1.0, -1.0,  1.0
]
