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
    public var depthShadowPipeline: DepthShadowPipeline
    
    init() {
        pbrPipeline = PbrPipeline()
//        pointPipeline = try PointPipeline()
        graphPipeline = GraphPipeline()
        depthShadowPipeline = DepthShadowPipeline()
    }
    
    func initialize() throws {
        try pbrPipeline.initialize()
        try graphPipeline.initialize()
        try depthShadowPipeline.initialize()
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        try pbrPipeline.render(renderEncoder: renderEncoder, frame: frame)
//        try pointPipeline.render(renderEncoder: renderEncoder, frame: frame)
        try graphPipeline.render(renderEncoder: renderEncoder, frame: frame)
    }
    
    func clearDrawables() {
        pbrPipeline.clearDrawables()
        graphPipeline.clearDrawables()
    }
}
