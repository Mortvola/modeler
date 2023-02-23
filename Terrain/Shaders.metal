//
//  Shaders.metal
//  Terrain
//
//  Created by Richard Shields on 2/23/23.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

vertex ColorInOut vertexShader(
    Vertex in [[stage_in]],
    constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]]
) {
    ColorInOut out;

    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.texCoord = in.texCoord;

    return out;
}

fragment float4 fragmentShader(
    ColorInOut in [[stage_in]],
    constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
    texture2d<half> colorMap     [[ texture(TextureIndexColor) ]]
) {
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);

    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);

    return float4(colorSample);
}

struct VertexIn {
    packed_float3 position;
    packed_float2 texcoords;
    packed_float3 normal;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut simpleVertexShader(
    const device VertexIn* vertexArray [[ buffer(0) ]],
    unsigned int vid [[ vertex_id ]]
) {
    VertexIn vertexIn = vertexArray[vid];
    
    VertexOut vertexOut;
    
    vertexOut.position = float4(vertexIn.position, 1.0);
    vertexOut.color = float4(1.0, 1.0, 1.0, 1.0);
    
    return vertexOut;
}

fragment half4 simpleFragmentShader(VertexOut interpolated [[stage_in]]) {
    return half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]);
}
