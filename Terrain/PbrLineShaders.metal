//
//  LineShader.metal
//  Terrain
//
//  Created by Richard Shields on 2/28/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

float DistributionGGX(float3 N, float3 H, float roughness);
float GeometrySmith(float NdotV, float NdotL, float roughness);
float3 fresnelSchlick(float cosTheta, float3 F0);

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

    vertexOut.N = float3(0.0, 1.0, 0.0);
    vertexOut.cameraPos = uniforms.cameraPos;
    vertexOut.V = normalize(uniforms.cameraPos - in.position);
    
    float3 albedo = float3(0.1, 0.1, 0.1); // pow(albedoMap.sample(sampler, fragmentIn.texCoords).rgb, float3(2.2));
    float metallic = 0.0; // metallicMap.sample(sampler, fragmentIn.texCoords).r;
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

    vertexOut.Lo = Lo;
    
    float4 position = float4(in.position.x, Lo.y * 2, in.position.z, 1.0);
    
    vertexOut.worldPos = position;
    
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * modelMatrix * position;

    vertexOut.color = float4(1.0, 0.0, 0.0, 1.0);
    
    return vertexOut;
}

float3 computeLo(
    float3 albedo,
    float metallic,
    float roughness,
    float3 N,
    float3 V,
    float3 L,
    float3 radiance
) {
    // calculate reflectance at normal incidence; if dia-electric (like plastic) use F0
    // of 0.04 and if it's a metal, use the albedo color as F0 (metallic workflow)
    float3 F0 = float3(0.04);
    F0 = mix(F0, albedo, metallic);

    // For sunlight, don't attenuate
//    float3 lightColor = float3(1.0, 1.0, 1.0);
//    float attenuation = 1.0;
//    float3 radiance = lightColor * attenuation;

    // The vector from the fragment to the light source (L), the sun in our case,
    // is a fixed vector
//    float3 L = normalize(-lightVector);
    float3 H = normalize(V + L);
    
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float HdotV = clamp(dot(H, V), 0.0, 1.0);
    
    // Cook-Torrance BRDF
    float NDF = DistributionGGX(N, H, roughness);
    float G = GeometrySmith(NdotV, NdotL, roughness);
    float3 F = fresnelSchlick(HdotV, F0);
       
    float3 numerator = NDF * G * F;
    float denominator = 4.0 * NdotV * NdotL + 0.0001; // + 0.0001 to prevent divide by zero
    float3 specular = numerator / denominator;
    // specular = float3(0, 0, 0);
    
    // kS is equal to Fresnel
    float3 kS = F;
    // for energy conservation, the diffuse and specular light can't
    // be above 1.0 (unless the surface emits light); to preserve this
    // relationship the diffuse component (kD) should equal 1.0 - kS.
    float3 kD = float3(1.0) - kS;
    // multiply kD by the inverse metalness such that only non-metals
    // have diffuse lighting, or a linear blend if partly metal (pure metals
    // have no diffuse light).
    kD *= 1.0 - metallic;

    float3 Lo = (kD * albedo / 3.14159265359 + specular) * radiance * NdotL;
    
    return Lo;
}

