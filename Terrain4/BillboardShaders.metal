//
//  BillboardShaders.metal
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
    float4 color;
};

struct Vertex {
    float3 position;
    float2 texcoord;
};

vertex VertexOut billboardVertexShader
(
    VertexIn vertices [[stage_in]],
    const device FrameUniforms &uniforms [[ buffer(BufferIndexUniforms) ]],
    const device float4x4& modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    const device BillboardUniforms &pointUniforms [[ buffer(BufferIndexNodeUniforms) ]]
//    uint instanceId [[ instance_id ]]
//    uint vertexId [[ vertex_id ]]
) {
    VertexOut out;
    
    float2 meshVertex = vertices.position.xy;
    
    float4 position = uniforms.viewMatrix * modelMatrix * float4(0, 0, 0, 1);
    
    out.position = uniforms.projectionMatrix * (float4(meshVertex * pointUniforms.scale, 0, 0) + position);
    out.color = pointUniforms.color;
    out.texcoord = (meshVertex + 1) * 0.5;
    
    return out;
}

fragment float4 billboardFragmentShader
(
    VertexOut in [[stage_in]],
    texture2d<float> texture [[texture(TextureIndexColor)]],
    sampler sampler [[sampler(SamplerIndexSampler)]]
) {
    float color = is_null_texture(texture) ? 1.0 : max(texture.sample(sampler, in.texcoord).r - 0.2, 0.0);

    return float4(in.color.rgb, color);
}
