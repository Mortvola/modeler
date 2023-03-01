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

vertex VertexOut lineVertexShader(
    LineVertexIn in [[stage_in]],
    const device Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device matrix_float4x4& modelMatrix [[ buffer(BufferIndexModelMatrix) ]]
) {
    VertexOut vertexOut;
    
    float4 position = float4(in.position, 1.0);
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * modelMatrix * position;

    vertexOut.color = float4(1.0, 0.0, 0.0, 1.0);
    
    return vertexOut;
}

fragment float4 simpleFragmentShader(VertexOut interpolated [[stage_in]]) {
    return interpolated.color;
}

