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

vertex float4 shadowVertexShader
(
    VertexIn in [[stage_in]],
    const device FrameUniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device ModelMatrixUniforms *modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    const device int32_t &cascadeIndex [[ buffer(BufferIndexCascadeIndex) ]],
    uint instanceId [[ instance_id ]]
) {
    return uniforms.directionalLight.viewProjectionMatrix[cascadeIndex]
        * modelMatrix[instanceId].modelMatrix
        * float4(in.position, 1.0);
}
