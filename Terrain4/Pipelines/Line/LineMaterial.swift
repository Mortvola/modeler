//
//  LineMaterial.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation
import MetalKit
import Metal

class LineMaterial: Material {
//    let pipeline: MTLRenderPipelineState
    
    init() {
        super.init(name: "Line Material")
//        allocUniforms()
    }
    
    override func pipelineType() -> PipelineType {
        .linePipeline
    }

    required init(from decoder: Decoder) throws {
//        self.pipeline = try LineMaterial.buildPipeline()

        try super.init(from: decoder)
    }
    
    override func prepare(renderEncoder: MTLRenderCommandEncoder, frame: Int) {
    }
}

