//
//  Shaders.metal
//  Terrain
//
//  Created by Richard Shields on 2/23/23.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
    float3 tangent [[attribute(VertexAttributeTangent)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoords;
    float3 tangentLightVector;
};

vertex VertexOut texturedVertexShader(
    VertexIn in [[stage_in]],
    const device FrameUniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device NodeUniforms& nodeUniforms [[ buffer(BufferIndexNodeUniforms) ]]
) {
    VertexOut vertexOut;
    
    float4 position = float4(in.position, 1.0);
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * nodeUniforms.modelMatrix * position;

    float3 T = normalize(nodeUniforms.normalMatrix * in.tangent);
    float3 N = normalize(nodeUniforms.normalMatrix * in.normal);
    T = normalize(T - dot(T, N) * N);
    float3 B = cross(N, T);
    
    float3x3 TBN = transpose(float3x3(T, B, N));
    vertexOut.tangentLightVector = TBN * normalize(uniforms.lightVector);

    vertexOut.texCoords = in.texCoord;
    
    return vertexOut;
}

fragment float4 texturedFragmentShader(
   VertexOut fragmentIn [[stage_in]],
   texture2d<float> baseColorTexture [[texture(TextureIndexColor)]],
   texture2d<float> normals [[texture(TextureIndexNormals)]],
   sampler sampler [[sampler(SamplerIndexSampler)]]
) {
    float3 color = baseColorTexture.sample(sampler, fragmentIn.texCoords).rgb;
    
    float3 normal = normals.sample(sampler, fragmentIn.texCoords).rgb;
    normal = normalize(normal * 2.0 - 1.0);

    float3 ambient = 0.1 * color;

    float diff = max(dot(normal, -fragmentIn.tangentLightVector), 0.0);
    float3 diffuse = diff * color;

    return float4(ambient + diffuse, 1.0);
}
