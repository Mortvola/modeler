//
//  RenderDelegate.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import Foundation
import MetalKit

class RenderDelegate: NSObject, MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        Renderer.shared.mtkView(view, drawableSizeWillChange: size)
    }
    
    init(file: SceneDocument, metalKitView: MTKView) throws {
        do {
            try Renderer.shared.initialize(file: file, metalKitView: metalKitView)
            Task {
                _ = try await MaterialManager.shared.addMaterial(device: metalKitView.device!, view: metalKitView, descriptor: nil)
                
                try await Renderer.shared.load(lat: 46.514279, lng: -121.456191, dimension: 128)
            }
        }
        catch {
            print(error)
            throw error
        }
    }
    
    func draw(in view: MTKView) {
        try? Renderer.shared.render(in: view)
    }
}
