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

//
//typedef struct
//{
//    float4 position [[position]];
//    float2 texCoord;
//} ColorInOut;
//
//vertex ColorInOut vertexShader(
//    Vertex in [[stage_in]],
//    constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]]
//) {
//    ColorInOut out;
//
//    float4 position = float4(in.position, 1.0);
//    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
//    out.texCoord = in.texCoord;
//
//    return out;
//}
//
//fragment float4 fragmentShader(
//    ColorInOut in [[stage_in]],
//    constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
//    texture2d<half> colorMap     [[ texture(TextureIndexColor) ]]
//) {
//    constexpr sampler colorSampler(mip_filter::linear,
//                                   mag_filter::linear,
//                                   min_filter::linear);
//
//    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);
//
//    return float4(colorSample);
//}

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
    const device Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device matrix_float4x4& modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    const device matrix_float3x3& normalMatrix [[ buffer(BufferIndexNormalMatrix) ]]
) {
    VertexOut vertexOut;
    
    float4 position = float4(in.position, 1.0);
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * modelMatrix * position;

    float3 T = normalize(normalMatrix * in.tangent);
    float3 N = normalize(normalMatrix * in.normal);
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
