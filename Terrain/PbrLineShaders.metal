//
//  LineShader.metal
//  Terrain
//
//  Created by Richard Shields on 2/28/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

struct LineVertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float4 worldPos;
    float3 N;
    float3 V;
    float3 lightVector;
    float3 cameraPos;
    float3 Lo;
    float3 c;
};

float3 computeLo(
    float3 albedo,
    float metallic,
    float roughness,
    float3 viewPos,
    float3 worldPos,
    float3 lightVector,
    float3 radiance
);

vertex VertexOut pbrLineVertexShader(
    LineVertexIn in [[stage_in]],
    const device Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device matrix_float4x4& modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    texture2d<float> normalMap [[texture(TextureIndexNormals)]],
    texture2d<float> metallicMap [[texture(TextureIndexMetallic)]],
    texture2d<float> roughnessMap [[texture(TextureIndexRoughness)]],
    sampler sampler [[sampler(SamplerIndexSampler)]]
) {
    VertexOut vertexOut;
    
    // float4 position = float4(in.position, 1.0);

    vertexOut.N = normalize(float3(0.0, 1.0, -1.0));
    vertexOut.cameraPos = uniforms.cameraPos;
    vertexOut.V = normalize(uniforms.cameraPos - in.position);
    
    float3 albedo = float3(0.0, 0.0, 1.0); // pow(albedoMap.sample(sampler, fragmentIn.texCoords).rgb, float3(2.2));
    float metallic = 1.0; // metallicMap.sample(sampler, fragmentIn.texCoords).r;
    float roughness = 1.0; // roughnessMap.sample(sampler, fragmentIn.texCoords).r;
    float ao = 1.0;
    
    float distance = length(uniforms.lightPos - in.position);
    float attenuation = 1.0 / (distance * distance);
    float3 radiance = uniforms.lightColor * attenuation;
    vertexOut.lightVector = normalize(uniforms.lightPos - in.position);

    float3 Lo = computeLo(albedo, metallic, roughness, vertexOut.N, vertexOut.V, vertexOut.lightVector, radiance);
    
    // ambient lighting (note that the next IBL tutorial will replace
    // this ambient lighting with environment lighting).
    float3 ambient = float3(0.03) * albedo * ao;

    float3 color = ambient + Lo;

    // HDR tonemapping
    color = color / (color + float3(1.0));

    // gamma correct
    color = pow(color, float3(1.0 / 2.2));

    vertexOut.Lo = Lo;
    vertexOut.c = color;
    
    float4 position = float4(in.position.x, in.position.y + Lo.y * 2, in.position.z, 1.0);
    
    vertexOut.worldPos = position;
    
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * modelMatrix * position;

    vertexOut.color = float4(1.0, 0.0, 0.0, 1.0);
    
    return vertexOut;
}
