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
    float3 tangentLightVector;
    float3 lightPos0; // these positions are in tangent space
    float3 lightPos1;
    float3 lightPos2;
    float3 lightPos3;
};

vertex VertexOut pbrVertexShader
(
    VertexIn in [[stage_in]],
    const device FrameUniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device ModelMatrixUniforms *instanceData [[ buffer(BufferIndexModelMatrix) ]],
    const device NodeUniforms& nodeUniforms [[ buffer(BufferIndexNodeUniforms) ]],
    uint instanceId [[ instance_id ]],
    uint vertexId [[ vertex_id ]]
) {
    VertexOut vertexOut;
    
    vertexOut.worldFragPos = float3(instanceData[instanceId].modelMatrix * float4(in.position, 1.0));
    
    vertexOut.position =  uniforms.projectionMatrix * uniforms.viewMatrix * float4(vertexOut.worldFragPos, 1.0);

    float3 T = normalize(instanceData[instanceId].normalMatrix * in.tangent);
    float3 N = normalize(instanceData[instanceId].normalMatrix * in.normal);
    T = normalize(T - dot(T, N) * N);
    float3 B = cross(N, T);

    float3x3 TBN = transpose(float3x3(T, B, N));
    
    vertexOut.tangentViewPos = TBN * uniforms.cameraPos;
    vertexOut.tangentFragPos = TBN * vertexOut.worldFragPos;
    
    // Convert positions to tangent space
    thread float3 *lightPos = &vertexOut.lightPos0;
    for (int i = 0; i < nodeUniforms.numberOfLights; i += 1) {
        lightPos[i] = TBN * nodeUniforms.lights[i].position;
    }
    
    vertexOut.tangentLightVector = TBN * uniforms.directionalLight.lightVector;
    
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

float getShadowedFactor
(
    float3 worldPos,
    const device DirectionalLight &directionalLight,
    depth2d_array<float> shadowMap
) {
    float shadowed = 0;
    
    for (int cascadeIndex = 0; cascadeIndex < 4; ++cascadeIndex) {
        float4 pos = directionalLight.viewProjectionMatrix[cascadeIndex] * float4(worldPos, 1.0);
        // NDC range from X -1 to 1, Y -1 to 1 and Z 0 to 1
        // The perspective divide isn't necessary for directional lights be we will
        // do it anyway to support point lights.
        float3 ndc = pos.xyz / pos.w; // After this the z coord holds the depth value
        
        // Convert coordinates to texture coordinates ranging from 0 to 1 in both directions.
        float2 coords = ndc.xy * 0.5 + 0.5;
        coords.y = 1 - coords.y;
        
        if (all(ndc.xyz < 1.0) && all(ndc.xyz > float3(-1, -1, 0))) {
            
            //    constexpr sampler sam (min_filter::linear, mag_filter::linear, compare_func::less);
            
            constexpr sampler shadowSampler(coord::normalized,
                                            address::clamp_to_edge,
                                            filter::linear,
                                            compare_func::greater_equal);
            
            float lightspaceDepth = ndc.z;
            
            for (int j = -1; j <= 1; ++j) {
                for (int i = -1; i <= 1; ++i) {
                    // Bias to help avoid shadow acne is applied through the setDeptBias method
                    shadowed += shadowMap.sample_compare(shadowSampler, coords, cascadeIndex, lightspaceDepth, int2(ndc.x + i, ndc.y + j));
                }
            }
            
            shadowed /= 9.0;
            
            break;
        }
    }

    return 1 - shadowed;
}

fragment float4 pbrFragmentShader
(
    VertexOut in [[stage_in]],
    const device FrameUniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device NodeUniforms& nodeUniforms [[ buffer(BufferIndexNodeUniforms) ]],
    const device PbrMaterialUniforms& materialUniforms [[ buffer(BufferIndexMaterialUniforms) ]],
    array<texture2d<float>, 4> textures [[texture(TextureIndexColor)]],
    texture2d<float> aoMap [[texture(TextureIndexAo)]],
    sampler sampler [[sampler(SamplerIndexSampler)]],
    depth2d_array<float> shadowMap [[texture(TextureIndexDepth)]]
) {
    float3 albedo = !is_null_texture(textures[0]) ? pow(textures[0].sample(sampler, in.texCoords).rgb, float3(2.2)) : pow(materialUniforms.albedo, float3(2.2));
    float3 normal = !is_null_texture(textures[1]) ? textures[1].sample(sampler, in.texCoords).rgb : materialUniforms.normals;
    float metallic = !is_null_texture(textures[2]) ? textures[2].sample(sampler, in.texCoords).r : materialUniforms.metallic;
    float roughness = !is_null_texture(textures[3]) ? textures[3].sample(sampler, in.texCoords).r : materialUniforms.roughness;
    float ao = 1.0; // aoMap.sample(sampler, fragmentIn.texCoords).r;
    
    float3 N = normalize(normal * 2 - 1);
    float3 V = normalize(in.tangentViewPos - in.tangentFragPos);

    float3 Lo = 0;
    
    thread float3 *tangentLightPos = &in.lightPos0;
    for (int i = 0; i < nodeUniforms.numberOfLights; i++) {
        //    if (uniforms.pointLight) {
        float distance = length(tangentLightPos[i] - in.tangentFragPos);
        float attenuation = 1.0 / (distance * distance);
        float3 radiance = nodeUniforms.lights[i].intensity * attenuation;
        float3 L = normalize(tangentLightPos[i] - in.tangentFragPos);
        
        Lo += computeLo(albedo, metallic, roughness, N, V, L, radiance);
    }

    // Directional light
    float3 radiance = uniforms.directionalLight.lightColor;
    float3 L = normalize(-in.tangentLightVector);

    float shadowFactor = getShadowedFactor(in.worldFragPos, uniforms.directionalLight, shadowMap);
    
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
