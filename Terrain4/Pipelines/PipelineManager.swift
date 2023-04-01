//
//  PipelineManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import Foundation
import MetalKit

class PipelineManager {
    public var depthShadowPipeline: DepthShadowPipeline
    
    let samplerState: MTLSamplerState

    var opaquePipelnes: [Pipeline] = []
    var transparentPipelines: [Pipeline] = []
    
    init() {
        samplerState = PipelineManager.buildSamplerState()

        depthShadowPipeline = DepthShadowPipeline()
    }
    
    func initialize() throws {
        try depthShadowPipeline.initialize()
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        renderEncoder.setFragmentSamplerState(samplerState, index: SamplerIndex.sampler.rawValue)

        for pipeline in opaquePipelnes {
            try pipeline.render(renderEncoder: renderEncoder, frame: frame)
        }
    }
    
    func transparentRender(renderEncoder: MTLRenderCommandEncoder, frame: Int) throws {
        for pipeline in transparentPipelines {
            try pipeline.render(renderEncoder: renderEncoder, frame: frame)
        }
    }
    
    func addPipeline(type: PipelineType, transparent: Bool) throws -> Pipeline? {
        var pipeline: Pipeline? = nil
        
        switch type {
        case .pbrPipeline:
            pipeline = PbrPipeline()
            
        case .billboardPipeline:
            pipeline = BillboardPipeline()

        case .graphPipeline:
            pipeline = GraphPipeline()
        }

        if let pipeline = pipeline {
            try pipeline.initialize(transparent: transparent)

            if transparent {
                transparentPipelines.append(pipeline)
            }
            else {
                opaquePipelnes.append(pipeline)
            }
        }
        
        return pipeline
    }
    
    func addMaterial(_ material: Material, using type: PipelineType, on object: RenderObject) throws {
        var pipeline: Pipeline? = nil
        
        if material.transparent {
            pipeline = transparentPipelines.first(where: { $0.type == type})
        }
        else {
            pipeline = opaquePipelnes.first(where: { $0.type == type})
        }
        
        // If the pipeline was not found then create one and add it.
        if pipeline == nil {
            pipeline = try addPipeline(type: type, transparent: material.transparent)
        }
        
        if let pipeline = pipeline {
            pipeline.addMaterial(material: object.material!)
            pipeline.prepareObject(object: object)
        }
    }
    
    func clearDrawables() {
        for pipeline in opaquePipelnes {
            pipeline.clearDrawables()
        }
        
        for pipeline in transparentPipelines {
            pipeline.clearDrawables()
        }
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
