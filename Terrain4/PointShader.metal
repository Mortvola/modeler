//
//  PointShader.metal
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
};

struct VertexOut {
    float4 position [[position]];
    float pointSize [[point_size]];
    float4 color;
};

vertex VertexOut pointVertexShader(
    VertexIn in [[stage_in]],
    const device FrameUniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device PointUniforms& pointUniforms [[ buffer(BufferIndexNodeUniforms) ]],
    const device int32_t &cascadeIndex [[ buffer(BufferIndexCascadeIndex) ]]
) {
    VertexOut out;
    
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * pointUniforms.modelMatrix * float4(in.position, 1.0);
    out.pointSize = pointUniforms.size;
    out.color = pointUniforms.color;
    
    return out;
}

fragment float4 pointFragmentShader(
   VertexOut in [[stage_in]]
) {
    float4 color = in.color;

    return color;
}
