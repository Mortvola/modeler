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
    float3 lightPos0;
    float3 lightPos1;
    float3 lightPos2;
    float3 lightPos3;
    float3 normal;
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
    
    float3 worldVertexPosition = float3(modelMatrix * float4(in.position, 1.0));
    
    vertexOut.position =  uniforms.projectionMatrix * uniforms.viewMatrix * float4(worldVertexPosition, 1.0);

    float3 T = normalize(normalMatrix * in.tangent);
    float3 N = normalize(normalMatrix * in.normal);
    T = normalize(T - dot(T, N) * N);
    float3 B = cross(N, T);

    float3x3 TBN = transpose(float3x3(T, B, N));
    
    vertexOut.viewPos = TBN * uniforms.cameraPos;
    vertexOut.fragPos = TBN * worldVertexPosition;
    vertexOut.normal = TBN * (modelMatrix * float4(in.normal, 0.0)).xyz;
    
    thread float3 *lightPos = &vertexOut.lightPos0;
    for (int i = 0; i < lights.numberOfLights; i += 1) {
        lightPos[i] = TBN * lights.position[i];
    }
    
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

fragment float4 pbrFragmentShader(
    VertexOut in [[stage_in]],
    const device Lights& lights [[ buffer(BufferIndexLightPos) ]],
    texture2d<float> albedoMap [[texture(TextureIndexColor)]],
    texture2d<float> normalMap [[texture(TextureIndexNormals)]],
    texture2d<float> metallicMap [[texture(TextureIndexMetallic)]],
    texture2d<float> roughnessMap [[texture(TextureIndexRoughness)]],
    texture2d<float> aoMap [[texture(TextureIndexAo)]],
    sampler sampler [[sampler(SamplerIndexSampler)]]
) {
    float3 albedo = pow(albedoMap.sample(sampler, in.texCoords).rgb, float3(2.2));
    
    float3 tNormal = normalize(normalMap.sample(sampler, in.texCoords).rgb * 2 - 1);
    // float3 tNormal = normalize(float3(0, 0, 5)); // in.normal;

    float metallic = metallicMap.sample(sampler, in.texCoords).r;
    float roughness = roughnessMap.sample(sampler, in.texCoords).r;
    float ao = 1.0; // aoMap.sample(sampler, fragmentIn.texCoords).r;
    
    float3 N = tNormal;
    float3 V = normalize(in.viewPos - in.fragPos);

    float3 Lo = 0;
    
    thread float3 *lightPos = &in.lightPos0;
    for (int i = 0; i < lights.numberOfLights; i++) {
        //    if (uniforms.pointLight) {
        float distance = length(lightPos[i] - in.fragPos);
        float attenuation = 1.0 / (distance * distance);
        float3 radiance = lights.intensity[i] * attenuation;
        float3 L = normalize(lightPos[i] - in.fragPos);
        //    }
        //    else {
        //        radiance = uniforms.lightColor;
        //        L = normalize(in.lightPos);
        //    }
        
        Lo += computeLo(albedo, metallic, roughness, N, V, L, radiance);
    }

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
