//
//  LineShader.metal
//  Terrain
//
//  Created by Richard Shields on 2/28/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

struct LineVertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut lineVertexShader
(
    LineVertexIn in [[stage_in]],
    const device FrameConstants& frameConstants [[ buffer(BufferIndexFrameConstants) ]],
    const device float4x4& modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    const device NodeUniforms& nodeUniforms [[ buffer(BufferIndexNodeUniforms) ]]
) {
    VertexOut vertexOut;
    
    float4 position = float4(in.position, 1.0);
    vertexOut.position = frameConstants.projectionMatrix * frameConstants.viewMatrix * modelMatrix * position;

    vertexOut.color = nodeUniforms.color;
    
    return vertexOut;
}

fragment float4 simpleFragmentShader(VertexOut in [[stage_in]]) {
    return in.color;
}

