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
    
    init(device: MTLDevice, view: MTKView) throws {
        pbrPipeline = try PbrPipeline(device: device, view: view)
        pointPipeline = try PointPipeline(device: device, view: view)
    }
}
