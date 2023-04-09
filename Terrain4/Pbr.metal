//
//  Pbr.metal
//  Terrain
//
//  Created by Richard Shields on 3/5/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

float DistributionGGX(float NdotH, float roughness)
{
    float a = roughness*roughness;
    float a2 = a*a;
    float NdotH2 = NdotH*NdotH;

    float nom   = a2;
//    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    float denom = max((NdotH2 * (a2 - 1.0) + 1.0), 1e-3);
    denom = M_PI_F * denom * denom;

    return nom / denom;
}

// ----------------------------------------------------------------------------
float GeometrySchlickGGX(float NdotX, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float nom   = NdotX;
    float denom = NdotX * (1.0 - k) + k;

    return nom / denom;
}

// ----------------------------------------------------------------------------
float GeometrySmith(float NdotV, float NdotL, float roughness)
{
    float ggx2 = GeometrySchlickGGX(NdotV, roughness);
    float ggx1 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}

// ----------------------------------------------------------------------------
float3 fresnelSchlick(float cosTheta, float3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
//    return F0 + (1.0 - F0) * pow(2, -5.55473 * cosTheta - 6.98316 * cosTheta);
}

float3 getNormalFromMap(float3 tNormal, float3 normal, float3 worldPosition, float2 texCoords) {
    // Transform tanget space normal into world space...
    float3 tangentNormal = tNormal * 2.0 - 1.0;

    float3 Q1  = dfdx(worldPosition);
    float3 Q2  = dfdy(worldPosition);
    float2 st1 = dfdx(texCoords);
    float2 st2 = dfdy(texCoords);

    float3 N   = normalize(normal);
    float3 T  = normalize(Q1 * st2.y - Q2 * st1.y);
    float3 B  = -normalize(cross(N, T));
    matrix_float3x3 TBN = matrix_float3x3(T, B, N);

    return normalize(TBN * tangentNormal);
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

    float3 H = normalize(V + L);
    
    float NdotV = saturate(dot(N, V));
    float NdotL = saturate(dot(N, L));
//    float HdotV = clamp(dot(H, V), 0.0, 1.0);
    float HdotL = saturate(dot(H, L));
    float NdotH = saturate(dot(N, H));
    
    // Cook-Torrance BRDF
    float NDF = DistributionGGX(NdotH, roughness);
    float G = GeometrySmith(NdotV, NdotL, roughness);
    float3 F = fresnelSchlick(HdotL, F0);
       
    float3 numerator = NDF * G * F;
    float denominator = 4.0; // * NdotV * NdotL + 0.0001; // + 0.0001 to prevent divide by zero
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
    kD *= 1.0 - metallic;

    float3 Lo = (kD * albedo / M_PI_F + specular) * NdotL * radiance;
    
    return Lo;
}

