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
    public let pointPipeline: PointPipeline
    public let billboardPipeline: BillboardPipeline
    public var depthShadowPipeline: DepthShadowPipeline
    
    init() throws {
        pbrPipeline = try PbrPipeline()
        pointPipeline = try PointPipeline()
        billboardPipeline = try BillboardPipeline()
        depthShadowPipeline = try DepthShadowPipeline()        
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        try pbrPipeline.render(renderEncoder: renderEncoder, frame: frame)
        try pointPipeline.render(renderEncoder: renderEncoder, frame: frame)
        try billboardPipeline.render(renderEncoder: renderEncoder, frame: frame)
    }
}
