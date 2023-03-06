//
//  Errors.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation

enum Errors: Error {
    case invalidMaterial
    case invalidTexture
    case downloadFailed
    case depthStateCreationFailed
    case makeFunctionError
    case createDeviceFailed
    case makeCommandQueueFailed
    case makeBufferFailed
    case makeDepthStencilStateFailed
}
