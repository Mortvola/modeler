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
    float3 tangentViewPos;
    float3 tangentFragPos;
    float3 worldFragPos;
    float3 lightVector;
    float3 lightPos0;
    float3 lightPos1;
    float3 lightPos2;
    float3 lightPos3;
//    float3 tangentNormal;
};

matrix_float3x3 subMatrix3x3(matrix_float4x4 m4x4) {
    return matrix_float3x3(
       m4x4[0][0], m4x4[0][1], m4x4[0][2],
        m4x4[1][0], m4x4[1][1], m4x4[1][2],
        m4x4[2][0], m4x4[2][1], m4x4[2][2]
    );
}

vertex VertexOut pbrVertexShader(
    VertexIn in [[stage_in]],
    const device Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device matrix_float4x4& modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    const device matrix_float3x3& normalMatrix [[ buffer(BufferIndexNormalMatrix) ]],
    const device Lights& lights [[ buffer(BufferIndexLightPos) ]]
) {
    VertexOut vertexOut;
    
    vertexOut.worldFragPos = float3(modelMatrix * float4(in.position, 1.0));
    
    vertexOut.position =  uniforms.projectionMatrix * uniforms.viewMatrix * float4(vertexOut.worldFragPos, 1.0);

    float3 T = normalize(normalMatrix * in.tangent);
    float3 N = normalize(normalMatrix * in.normal);
    T = normalize(T - dot(T, N) * N);
    float3 B = cross(N, T);

    float3x3 TBN = transpose(float3x3(T, B, N));
    
    vertexOut.tangentViewPos = TBN * uniforms.cameraPos;
    vertexOut.tangentFragPos = TBN * vertexOut.worldFragPos;
//    vertexOut.tangentNormal = TBN * (modelMatrix * float4(in.normal, 0.0)).xyz;
    
    // Convert positions to tangent space
    thread float3 *lightPos = &vertexOut.lightPos0;
    for (int i = 0; i < lights.numberOfLights; i += 1) {
        lightPos[i] = TBN * lights.position[i];
    }
    
    vertexOut.lightVector = TBN * uniforms.lightVector;
    
    vertexOut.texCoords = in.texCoord;

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

float shadowed(
             float3 worldPos,
             const device float4x4 &viewProjectionMatrix,
             depth2d<float, access::sample> shadowMap
) {
    float4 pos = viewProjectionMatrix * float4(worldPos, 1.0);
    // NDC range from X -1 to 1, Y -1 to 1 and Z 0 to 1
    // The perspective divide isn't necessary for directional lights be we will
    // do it anyway to support point lights.
    float3 ndc = pos.xyz / pos.w; // After this the z coord holds the depth value
    
    // Convert coordinates to texture coordinates ranging from 0 to 1 in both directions.
    float2 coords = ndc.xy * 0.5 + 0.5;
    coords.y = 1 - coords.y;
    
    constexpr sampler shadowSampler(coord::normalized,
                                    address::clamp_to_edge,
                                    filter::linear,
                                    compare_func::greater_equal);

    // Bias to help avoid shadow acne.
    // Todo: adjust this based on the light angle to the surface
    float bias = 0.005;
    float shadowed = shadowMap.sample_compare(shadowSampler, coords, ndc.z - bias);
    
    return shadowed;
}

fragment float4 pbrFragmentShader(
    VertexOut in [[stage_in]],
    const device Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device Lights& lights [[ buffer(BufferIndexLightPos) ]],
    texture2d<float> albedoMap [[texture(TextureIndexColor)]],
    texture2d<float> normalMap [[texture(TextureIndexNormals)]],
    texture2d<float> metallicMap [[texture(TextureIndexMetallic)]],
    texture2d<float> roughnessMap [[texture(TextureIndexRoughness)]],
    texture2d<float> aoMap [[texture(TextureIndexAo)]],
    sampler sampler [[sampler(SamplerIndexSampler)]],
    depth2d<float, access::sample> shadowMap [[texture(TextureIndexDepth)]]
) {
    float3 albedo = pow(albedoMap.sample(sampler, in.texCoords).rgb, float3(2.2));
    
    float metallic = metallicMap.sample(sampler, in.texCoords).r;
    float roughness = roughnessMap.sample(sampler, in.texCoords).r;
    float ao = 1.0; // aoMap.sample(sampler, fragmentIn.texCoords).r;
    
    float3 N = normalize(normalMap.sample(sampler, in.texCoords).rgb * 2 - 1);
    float3 V = normalize(in.tangentViewPos - in.tangentFragPos);

    float3 Lo = 0;
    
    thread float3 *tangentLightPos = &in.lightPos0;
    for (int i = 0; i < lights.numberOfLights; i++) {
        //    if (uniforms.pointLight) {
        float distance = length(tangentLightPos[i] - in.tangentFragPos);
        float attenuation = 1.0 / (distance * distance);
        float3 radiance = lights.intensity[i] * attenuation;
        float3 L = normalize(tangentLightPos[i] - in.tangentFragPos);
        
        Lo += computeLo(albedo, metallic, roughness, N, V, L, radiance);
    }

    // Directional light
    float3 radiance = uniforms.lightColor;
    float3 L = normalize(-in.lightVector);

    float shadowFactor = 1 - shadowed(in.worldFragPos, uniforms.lightViewProjectionMatrix, shadowMap);
    
    Lo += computeLo(albedo, metallic, roughness, N, V, L, radiance) * shadowFactor;

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
