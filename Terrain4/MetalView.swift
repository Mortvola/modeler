//
//  MetalView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/26/23.
//

import Foundation
import MetalKit

class MetalView {
    static let shared = MetalView()
    
    let device: MTLDevice
    var view: MTKView?

    init() {
        let defaultDevice = MTLCreateSystemDefaultDevice()

        self.device = defaultDevice!
    }
}
