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
    
    init(file: SceneDocument) throws {
        do {
            try Renderer.shared.initialize(file: file)
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
