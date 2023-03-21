//
//  SkyboxShaders.metal
//  Terrain
//
//  Created by Richard Shields on 2/27/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 texCoords [[shared]];
};

vertex VertexOut skyboxVertexShader(
    VertexIn in [[stage_in]],
    const device FrameUniforms& uniforms [[ buffer(BufferIndexUniforms) ]]
) {
    VertexOut vertexOut;
    
    float4 position = float4(in.position.xyz, 1.0);
    
    // Strip out the translation components from the view matrix (we want the skybox
    // to be around the camera even when the camera moves).
    float4x4 rotate = float4x4(
        uniforms.viewMatrix[0][0], uniforms.viewMatrix[0][1], uniforms.viewMatrix[0][2], 0,
        uniforms.viewMatrix[1][0], uniforms.viewMatrix[1][1], uniforms.viewMatrix[1][2], 0,
        uniforms.viewMatrix[2][0], uniforms.viewMatrix[2][1], uniforms.viewMatrix[2][2], 0,
        0, 0, 0, 1
    );

    // Replace the z value with the homgenous coordinate (w) so that z becomes 1
    // after the perspective divide (1 is the maximum depth).
    vertexOut.position = (uniforms.projectionMatrix * rotate * position).xyww;
    vertexOut.texCoords = in.position;
    
    return vertexOut;
}

fragment float4 skyboxFragmentShader(
    VertexOut fragmentIn [[stage_in]],
    texturecube<float> baseColorTexture [[texture(TextureIndexColor)]],
    sampler sampler [[sampler(SamplerIndexSampler)]]
) {
    float3 color = baseColorTexture.sample(sampler, fragmentIn.texCoords).rgb;
    
    return float4(color, 1.0);
}
