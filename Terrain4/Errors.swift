//
//  Errors.swift
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

import Foundation

enum Errors: Error {
    case deviceNotSet
    case viewNotSet
    case uniformsNotSet
    case invalidMaterial
    case invalidTexture
    case downloadFailed
    case depthStateCreationFailed
    case makeFunctionError
    case createDeviceFailed
    case makeCommandQueueFailed
    case makeBufferFailed
    case makeDepthStencilStateFailed
    case notImplemented
    case modelNotSelected
    case unknownGeometryType
    case mallocError
    case invalidURL
    case invalidAssetWriterInput
    case objectTypeMismatch
    case invalidObject
}
