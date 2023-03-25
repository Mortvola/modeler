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
    
    init(device: MTLDevice, view: MTKView) throws {
        pbrPipeline = try PbrPipeline(device: device, view: view)
        pointPipeline = try PointPipeline(device: device, view: view)
        billboardPipeline = try BillboardPipeline(device: device, view: view)
        depthShadowPipeline = try DepthShadowPipeline(device: device, view: view)        
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        try pbrPipeline.render(renderEncoder: renderEncoder, frame: frame)
        try pointPipeline.render(renderEncoder: renderEncoder, frame: frame)
        try billboardPipeline.render(renderEncoder: renderEncoder, frame: frame)
    }
}
