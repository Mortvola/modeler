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
    public var imageBlockPipeline: MTLRenderPipelineState?
    public var blendFragmentsPipeline: MTLRenderPipelineState?
    
    let samplerState: MTLSamplerState

    var opaquePipelnes: [Pipeline] = []
    var transparentPipelines: [Pipeline] = []
    
    init() {
        samplerState = PipelineManager.buildSamplerState()

        depthShadowPipeline = DepthShadowPipeline()
    }
    
    func initialize() throws {
        imageBlockPipeline = try buildImageBlockPipeline()
        blendFragmentsPipeline = try buildBlendFragmentsPipeline()
        
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
            
        case .linePipeline:
            pipeline = LinePipeline()
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
    
    private func buildImageBlockPipeline() throws -> MTLRenderPipelineState {
        let library = MetalView.shared.device.makeDefaultLibrary()

        let tileFunction = library?.makeFunction(name: "initTransparentFragmentStore")
        
        guard let tileFunction = tileFunction else {
            throw Errors.makeFunctionError
        }

        let descr = MTLTileRenderPipelineDescriptor()
        descr.label = "Image Block Pipeline"
        descr.tileFunction = tileFunction
        descr.colorAttachments[0].pixelFormat = MetalView.shared.view!.colorPixelFormat
        descr.threadgroupSizeMatchesTileSize = true
        
        let (renderPipelineState, _) = try MetalView.shared.device.makeRenderPipelineState(tileDescriptor: descr, options: [])
        
        return renderPipelineState
    }
    
    private func buildBlendFragmentsPipeline() throws -> MTLRenderPipelineState {
        let library = MetalView.shared.device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "quadPassVertex")
        let fragmentFunction = library?.makeFunction(name: "blendFragments")
        
        if vertexFunction == nil || fragmentFunction == nil {
            throw Errors.makeFunctionError
        }
        
        let descr = MTLRenderPipelineDescriptor()
        descr.label = "Blend Fragments"
        descr.rasterSampleCount = MetalView.shared.view!.sampleCount
        descr.vertexFunction = vertexFunction
        descr.fragmentFunction = fragmentFunction
        descr.vertexDescriptor = nil
        
        descr.colorAttachments[0].pixelFormat = MetalView.shared.view!.colorPixelFormat
        descr.depthAttachmentPixelFormat = MetalView.shared.view!.depthStencilPixelFormat
        descr.stencilAttachmentPixelFormat = MTLPixelFormat.invalid

        return try MetalView.shared.device.makeRenderPipelineState(descriptor: descr)
    }
}
