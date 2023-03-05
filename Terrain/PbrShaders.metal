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
float GeometrySmith(float NdotV, float NdotL, float roughness)
{
//    float NdotV = max(dot(N, V), 0.0);
//    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = GeometrySchlickGGX(NdotV, roughness);
    float ggx1 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}

// ----------------------------------------------------------------------------
float3 fresnelSchlick(float cosTheta, float3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
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
    float3 tangentViewPos;
    float3 tangentWorldPos;
    float3 tangentNormal;
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
    
    float3 worldPosition = float3(modelMatrix * float4(vertexIn.position, 1.0));
    float3 normal = subMatrix3x3(modelMatrix) * vertexIn.normal;
    
    vertexOut.position =  uniforms.projectionMatrix * uniforms.viewMatrix * float4(worldPosition, 1.0);

//    float3 T = normalize(normalMatrix * vertexIn.tangent);
//    float3 N = normalize(normalMatrix * vertexIn.normal);
//    T = normalize(T - dot(T, N) * N);
//    float3 B = cross(N, T);
//
//    float3x3 TBN = transpose(float3x3(T, B, N));
//    vertexOut.tangentLightVector = TBN * normalize(uniforms.lightVector);
//    vertexOut.tangentViewPos  = TBN * uniforms.cameraPos;
//    vertexOut.tangentWorldPos  = TBN * worldPosition;
//    vertexOut.tangentNormal = TBN * normal;

    vertexOut.tangentLightVector = normalize(uniforms.lightVector);
    vertexOut.tangentViewPos  = uniforms.cameraPos;
    vertexOut.tangentWorldPos  = worldPosition;
    vertexOut.tangentNormal = normal;

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
    float3 albedo = float3(1.0, 0.0, 0.0); // pow(albedoMap.sample(sampler, fragmentIn.texCoords).rgb, float3(2.2));
    float3 tNormal = float3(0.5, 1, 0.5); // normalMap.sample(sampler, fragmentIn.texCoords).rgb;
    float metallic = 1.0; // metallicMap.sample(sampler, fragmentIn.texCoords).r;
    float roughness = 1.0; // roughnessMap.sample(sampler, fragmentIn.texCoords).r;
    float ao = 1.0; // aoMap.sample(sampler, fragmentIn.texCoords).r;
    
    float3 N = normalize(tNormal * 2 - 1);
    float3 V = normalize(fragmentIn.tangentViewPos - fragmentIn.tangentWorldPos);
   
//    float distance = length(uniforms.lightPos - fragmentIn.tangentWorldPos);
//    float attenuation = 1.0 / (distance * distance);
//    float3 radiance = uniforms.lightColor * attenuation;
//     float3 L = normalize(uniforms.lightPos - fragmentIn.tangentWorldPos);
    float3 radiance = float3(15, 15, 15);
    float3 L = float3(0.0, 1.0, 0.0);

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
