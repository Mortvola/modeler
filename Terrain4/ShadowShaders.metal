//
//  ShadowShaderes.metal
//  Terrain4
//
//  Created by Richard Shields on 3/18/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
};

vertex float4 shadowVertexShader(
    VertexIn in [[stage_in]],
    const device FrameUniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device NodeUniforms& nodeUniforms [[ buffer(BufferIndexNodeUniforms) ]],
    const device int32_t &cascadeIndex [[ buffer(BufferIndexCascadeIndex) ]]
) {
    return uniforms.directionalLight.viewProjectionMatrix[cascadeIndex] * nodeUniforms.modelMatrix * float4(in.position, 1.0);
}
