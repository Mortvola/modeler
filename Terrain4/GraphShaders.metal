//
//  GraphShaders.metal
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

vertex VertexOut graphVertexShader
(
    VertexIn vertices [[stage_in]],
    const device FrameConstants &uniforms [[ buffer(BufferIndexFrameConstants) ]],
    const device ModelMatrixUniforms *instanceData [[ buffer(BufferIndexModelMatrix) ]],
    uint instanceId [[ instance_id ]],
    uint vertexId [[ vertex_id ]]
) {
    VertexOut out;
    
    float2 meshVertex = vertices.position.xy;
    
    float4 position = (uniforms.viewMatrix * instanceData[instanceId].modelMatrix)[3];
    
    out.position = uniforms.projectionMatrix * (position + float4(meshVertex, 0, 0));
    out.texcoord = vertices.texCoord;
    
    return out;
}

//[[visible]]
//float4 processTexel
//(
// texture2d<float> texture,
// sampler sampler,
// float2 texcoord,
// const device float *arg0,
// const device float *arg1,
// const device float *arg2
//);

//[[visible]]
//float4 processTexel(float4 color, float alpha);

fragment float4 graphFragmentShader
(
    VertexOut in [[stage_in]],
    const device GraphUniforms &graphUniforms [[ buffer(BufferIndexMaterialUniforms) ]],
    texture2d<float> texture [[texture(TextureIndexColor)]],
    sampler sampler [[sampler(SamplerIndexSampler)]]
) {
//    float color = is_null_texture(texture) ? 1.0 : max(texture.sample(sampler, in.texcoord).r - 0.2, 0.0);

//    return processTexel(texture, sampler, in.texcoord,
//                        &graphUniforms.arg[graphUniforms.argOffset[0]],
//                        &graphUniforms.arg[graphUniforms.argOffset[1]],
//                        &graphUniforms.arg[graphUniforms.argOffset[2]]);
//    return processTexel(texture, sampler, in.texcoord, float4(1, 1, 1, 1), 0.2, 0.0);

    return float4(1, 1, 1, 1);
//    return float4(pointUniforms.color.rgb, color);
//    return processTexel(pointUniforms.color, color);
}

[[stitchable]]
float readTextureRed(texture2d<float> texture, sampler sampler, float2 texcoord) {
    return is_null_texture(texture) ? 1.0 : texture.sample(sampler, texcoord).r;
}

[[stitchable]]
float subtract(float a, const device float *b) {
    return a - *b;
}

[[stitchable]]
float multiply(float a, float b) {
    return a * b;
}

[[stitchable]]
float maxValue(float a, const device float *b) {
    return max(a, *b);
}

[[stitchable]]
float4 assignAlpha(float color,  float a, const device float4 *parameters) {
    return float4(parameters->rgb, a);
}
