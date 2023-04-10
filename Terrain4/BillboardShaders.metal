
//
//  BillboardShaders.metal
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
#import "CommonTypes.h"

using namespace metal;

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
};

vertex VertexOut billboardVertexShader
(
    VertexIn vertices [[stage_in]],
    const device FrameConstants &frameConstants [[ buffer(BufferIndexFrameConstants) ]],
    const device ModelMatrixUniforms *modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    uint instanceId [[ instance_id ]],
    uint vertexId [[ vertex_id ]]
) {
    VertexOut out;
    
    float2 meshVertex = vertices.position.xy;
    
    float4 position = (frameConstants.viewMatrix * modelMatrix[instanceId].modelMatrix)[3];
    
    out.position = frameConstants.projectionMatrix * (position + float4(meshVertex, 0, 0));
    out.texcoord = vertices.texCoord;
    
    return out;
}

fragment float4 billboardFragmentShader
(
    VertexOut in [[stage_in]],
    const device BillboardUniforms &billboardUniforms [[ buffer(BufferIndexMaterialUniforms)]],
    texture2d<float> texture [[texture(TextureIndexColor)]],
    sampler sampler [[sampler(SamplerIndexSampler)]]
) {
    float alpha = is_null_texture(texture) ? 1.0 : max(texture.sample(sampler, in.texcoord).r - 0.2, 0.0);

    return float4(billboardUniforms.color.xyz, alpha);
}

TransparentFragmentStore processTransparent
(
    float4 color,
    float4 position,
    TransparentFragmentValues fragmentValues
 );

fragment TransparentFragmentStore billboardFragmentTransparencyShader
(
    VertexOut in [[stage_in]],
    const device BillboardUniforms &billboardUniforms [[ buffer(BufferIndexMaterialUniforms)]],
    texture2d<float> texture [[texture(TextureIndexColor)]],
    sampler sampler [[sampler(SamplerIndexSampler)]],
    TransparentFragmentValues  fragmentValues [[imageblock_data]]
) {
    float alpha = is_null_texture(texture) ? 1.0 : max(texture.sample(sampler, in.texcoord).r - 0.2, 0.0);

    float4 color = float4(billboardUniforms.color.xyz, alpha);
    
    return processTransparent(color, in.position, fragmentValues);
}
