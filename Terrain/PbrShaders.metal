//
//  PbrShaders.metal
//  Terrain
//
//  Created by Richard Shields on 3/2/23.
//

#include <metal_stdlib>
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
    float3 viewPos;
    float3 fragPos;
    float3 lightPos;
    float3 lightVector;
};

matrix_float3x3 subMatrix3x3(matrix_float4x4 m4x4) {
    return matrix_float3x3(
       m4x4[0][0], m4x4[0][1], m4x4[0][2],
        m4x4[1][0], m4x4[1][1], m4x4[1][2],
        m4x4[2][0], m4x4[2][1], m4x4[2][2]
    );
}

vertex VertexOut pbrVertexShader(
    VertexIn vertexIn [[stage_in]],
    const device Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device matrix_float4x4& modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    const device matrix_float3x3& normalMatrix [[ buffer(BufferIndexNormalMatrix) ]]
) {
    VertexOut vertexOut;
    
    float3 worldVertexPosition = float3(modelMatrix * float4(vertexIn.position, 1.0));
    
    vertexOut.position =  uniforms.projectionMatrix * uniforms.viewMatrix * float4(worldVertexPosition, 1.0);

    float3 T = normalize(normalMatrix * vertexIn.tangent);
    float3 N = normalize(normalMatrix * vertexIn.normal);
    T = normalize(T - dot(T, N) * N);
    float3 B = cross(N, T);

    float3x3 TBN = transpose(float3x3(T, B, N));
    
    vertexOut.viewPos = TBN * uniforms.cameraPos;
    vertexOut.fragPos = TBN * worldVertexPosition;
    
    vertexOut.lightPos = TBN * uniforms.lightPos;
    vertexOut.lightVector = TBN * uniforms.lightVector;
    
    vertexOut.texCoords = vertexIn.texCoord;

    return vertexOut;
}

float3 computeLo(
    float3 albedo,
    float metallic,
    float roughness,
    float3 viewPos,
    float3 worldPos,
    float3 lightVector,
    float3 radiance
);

fragment float4 pbrFragmentShader(
    VertexOut fragmentIn [[stage_in]],
    const device Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    texture2d<float> albedoMap [[texture(TextureIndexColor)]],
    texture2d<float> normalMap [[texture(TextureIndexNormals)]],
    texture2d<float> metallicMap [[texture(TextureIndexMetallic)]],
    texture2d<float> roughnessMap [[texture(TextureIndexRoughness)]],
    texture2d<float> aoMap [[texture(TextureIndexAo)]],
    sampler sampler [[sampler(SamplerIndexSampler)]]
) {
#if 1
#if 1
    float3 albedo = pow(albedoMap.sample(sampler, fragmentIn.texCoords).rgb, float3(2.2));
#else
    float3 albedo = normalMap.sample(sampler, fragmentIn.texCoords).rgb;
#endif
#else
    float3 albedo = float3(0.0, 0.0, 1.0);
#endif
    
#if 1
#if 1
    float3 tNormal = normalMap.sample(sampler, fragmentIn.texCoords).rgb;
#else
    float3 tNormal = float3(0.5, 0.5, 1.0); // normalMap.sample(sampler, fragmentIn.texCoords).rgb;
#endif
#else
    float3 tNormal = float3(0.5, 1, 0); // float3(0.5, 0.5, 1.0); // normalMap.sample(sampler, fragmentIn.texCoords).rgb;
#endif
    
    float metallic = 0.5; // metallicMap.sample(sampler, fragmentIn.texCoords).r;
    float roughness = roughnessMap.sample(sampler, fragmentIn.texCoords).r;
    float ao = 1.0; // aoMap.sample(sampler, fragmentIn.texCoords).r;
    
    float3 N = normalize(tNormal * 2 - 1);
    float3 V = normalize(fragmentIn.viewPos - fragmentIn.fragPos);

    float3 L;
    float3 radiance;

    if (uniforms.pointLight) {
        float distance = length(fragmentIn.lightPos - fragmentIn.fragPos);
        float attenuation = 1.0 / (distance * distance + 0.001);
        radiance = uniforms.lightColor * attenuation;
        L = normalize(fragmentIn.lightPos - fragmentIn.fragPos);
    }
    else {
        radiance = uniforms.lightColor;
        L = normalize(fragmentIn.lightPos); // float3(0.0, 0.0, 1.0);
    }

    float3 Lo = computeLo(albedo, metallic, roughness, N, V, L, radiance);

    // ambient lighting (note that the next IBL tutorial will replace
    // this ambient lighting with environment lighting).
    float3 ambient = float3(0.03) * albedo * ao;

    float3 color = ambient + Lo;

    // HDR tonemapping
    color = color / (color + float3(1.0));

    // gamma correct
    color = pow(color, float3(1.0 / 2.2));

    return float4(color, 1.0);
}
