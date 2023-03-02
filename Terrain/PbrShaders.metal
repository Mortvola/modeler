//
//  PbrShaders.metal
//  Terrain
//
//  Created by Richard Shields on 3/2/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

float DistributionGGX(float3 N, float3 H, float roughness)
{
    float a = roughness*roughness;
    float a2 = a*a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;

    float nom   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = 3.14159265359 * denom * denom;

    return nom / denom;
}

// ----------------------------------------------------------------------------
float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}

// ----------------------------------------------------------------------------
float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = GeometrySchlickGGX(NdotV, roughness);
    float ggx1 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}
// ----------------------------------------------------------------------------
float3 fresnelSchlick(float cosTheta, float3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float2 texCoords;
    float3 normal;
    float3 cameraPos;
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
     const device matrix_float4x4& modelMatrix [[ buffer(BufferIndexModelMatrix) ]]
) {
    VertexOut vertexOut;
    
    vertexOut.texCoords = vertexIn.texCoord;
    vertexOut.worldPosition = float3(modelMatrix * float4(vertexIn.position, 1.0));
    vertexOut.normal = subMatrix3x3(modelMatrix) * vertexIn.normal;
    vertexOut.cameraPos = uniforms.cameraPos;
    vertexOut.lightVector = uniforms.lightVector;
    
    vertexOut.position =  uniforms.projectionMatrix * uniforms.viewMatrix * float4(vertexOut.worldPosition, 1.0);

    return vertexOut;
}

fragment float4 pbrFragmentShader(
    VertexOut fragmentIn [[stage_in]],
    const device PbrValues& pbrValues [[ buffer(BufferIndexPbrValues) ]]
) {
    float3 N = normalize(fragmentIn.normal);
    float3 V = normalize(fragmentIn.cameraPos - fragmentIn.worldPosition);

    // calculate reflectance at normal incidence; if dia-electric (like plastic) use F0
    // of 0.04 and if it's a metal, use the albedo color as F0 (metallic workflow)
    float3 F0 = float3(0.04);
    F0 = mix(F0, pbrValues.albedo, pbrValues.metallic);

    float3 lightColor = float3(1.0, 1.0, 1.0);
    
    // reflectance equation
    float3 Lo = float3(0.0);
    
//    for(int i = 0; i < 4; ++i)
//    {
    // calculate per-light radiance
    
    // The vector from the fragment to the light source (L), the sun in our case,
    // is a fixed vector
//    float3 L = normalize(lightPosition - fragmentIn.worldPosition);
    float3 L = -fragmentIn.lightVector;
    float3 H = normalize(V + L);
    
    // For sunlight, don't attenuate
//    float distance = length(lightPosition - fragmentIn.worldPosition);
//    float attenuation = 1.0 / (distance * distance);
//    float3 radiance = lightColor * attenuation;
    float3 radiance = lightColor;

    // Cook-Torrance BRDF
    float NDF = DistributionGGX(N, H, pbrValues.roughness);
    float G = GeometrySmith(N, V, L, pbrValues.roughness);
    float3 F = fresnelSchlick(clamp(dot(H, V), 0.0, 1.0), F0);
       
    float3 numerator = NDF * G * F;
    float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.0001; // + 0.0001 to prevent divide by zero
    float3 specular = numerator / denominator;
    
    // kS is equal to Fresnel
    float3 kS = F;
    // for energy conservation, the diffuse and specular light can't
    // be above 1.0 (unless the surface emits light); to preserve this
    // relationship the diffuse component (kD) should equal 1.0 - kS.
    float3 kD = float3(1.0) - kS;
    // multiply kD by the inverse metalness such that only non-metals
    // have diffuse lighting, or a linear blend if partly metal (pure metals
    // have no diffuse light).
    kD *= 1.0 - pbrValues.metallic;

    // scale light by NdotL
    float NdotL = max(dot(N, L), 0.0);

    // add to outgoing radiance Lo
    Lo += (kD * pbrValues.albedo / 3.14159265359 + specular) * radiance * NdotL;  // note that we already multiplied the BRDF by the Fresnel (kS) so we won't multiply by kS again
//    }
    
    // ambient lighting (note that the next IBL tutorial will replace
    // this ambient lighting with environment lighting).
    float3 ambient = float3(0.03) * pbrValues.albedo * pbrValues.ao;

    float3 color = ambient + Lo;

    // HDR tonemapping
    color = color / (color + float3(1.0));
    
    // gamma correct
    color = pow(color, float3(1.0 / 2.2));

    return float4(color, 1.0);
}
