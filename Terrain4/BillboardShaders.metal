
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
};

struct Vertex {
    float3 position;
    float2 texcoord;
};

vertex VertexOut billboardVertexShader
(
    VertexIn vertices [[stage_in]],
    const device FrameUniforms &uniforms [[ buffer(BufferIndexUniforms) ]],
    const device ModelMatrixUniforms *modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    uint instanceId [[ instance_id ]],
    uint vertexId [[ vertex_id ]]
) {
    VertexOut out;
    
    float2 meshVertex = vertices.position.xy;
    
    float4 position = (uniforms.viewMatrix * modelMatrix[instanceId].modelMatrix)[3];
    
    out.position = uniforms.projectionMatrix * (position + float4(meshVertex, 0, 0));
    out.texcoord = vertices.texCoord;
    
    return out;
}

fragment float4 billboardFragmentShader
(
    VertexOut in [[stage_in]],
    const device GraphUniforms &graphUniforms [[ buffer(BufferIndexMaterialUniforms) ]],
    texture2d<float> texture [[texture(TextureIndexColor)]],
    sampler sampler [[sampler(SamplerIndexSampler)]]
) {
    float color = is_null_texture(texture) ? 1.0 : max(texture.sample(sampler, in.texcoord).r - 0.2, 0.0);

    return float4(float3(1, 1, 1), color);
}
