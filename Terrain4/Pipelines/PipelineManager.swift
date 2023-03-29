//
//  PipelineManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import MetalKit

class PipelineManager {
    public let pbrPipeline: PbrPipeline
//    public let pointPipeline: PointPipeline
    public let graphPipeline: GraphPipeline
    public let billboardPipeline: BillboardPipeline
    public var depthShadowPipeline: DepthShadowPipeline
    
    let samplerState: MTLSamplerState

    init() {
        samplerState = PipelineManager.buildSamplerState()

        pbrPipeline = PbrPipeline()
//        pointPipeline = try PointPipeline()
        graphPipeline = GraphPipeline()
        billboardPipeline = BillboardPipeline()
        depthShadowPipeline = DepthShadowPipeline()
    }
    
    func initialize() throws {
        try pbrPipeline.initialize()
        try graphPipeline.initialize()
        try billboardPipeline.initialize()
        try depthShadowPipeline.initialize()
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        renderEncoder.setFragmentSamplerState(samplerState, index: SamplerIndex.sampler.rawValue)

        try pbrPipeline.render(renderEncoder: renderEncoder, frame: frame)
//        try pointPipeline.render(renderEncoder: renderEncoder, frame: frame)
//        try graphPipeline.render(renderEncoder: renderEncoder, frame: frame)
    }
    
    func transparentRender(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        try billboardPipeline.render(renderEncoder: renderEncoder, frame: frame)
    }
    
    func clearDrawables() {
        pbrPipeline.clearDrawables()
        billboardPipeline.clearDrawables()
        graphPipeline.clearDrawables()
    }
    
    private class func buildSamplerState() -> MTLSamplerState {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        return MetalView.shared.device.makeSamplerState(descriptor: samplerDescriptor)!
    }
}
