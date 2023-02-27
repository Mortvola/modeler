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

//
//typedef struct
//{
//    float4 position [[position]];
//    float2 texCoord;
//} ColorInOut;
//
//vertex ColorInOut vertexShader(
//    Vertex in [[stage_in]],
//    constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]]
//) {
//    ColorInOut out;
//
//    float4 position = float4(in.position, 1.0);
//    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
//    out.texCoord = in.texCoord;
//
//    return out;
//}
//
//fragment float4 fragmentShader(
//    ColorInOut in [[stage_in]],
//    constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
//    texture2d<half> colorMap     [[ texture(TextureIndexColor) ]]
//) {
//    constexpr sampler colorSampler(mip_filter::linear,
//                                   mag_filter::linear,
//                                   min_filter::linear);
//
//    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);
//
//    return float4(colorSample);
//}

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut simpleVertexShader(
    VertexIn in [[stage_in]],
    const device Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device matrix_float4x4& modelMatrix [[ buffer(BufferIndexModelMatrix) ]]
) {
    VertexOut vertexOut;
    
    float4 position = float4(in.position, 1.0);
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * modelMatrix * position;

    // Use a light gray color as the base.
    float3 color = float3(0.7, 0.7, 0.7);
    
    float3 ambient = 0.3 * color;

    float3 lightVector = normalize(-float3(0, -1, 1));
    float diff = max(dot(in.normal, lightVector), 0.0);
    float3 diffuse = diff * color;

    vertexOut.color = float4(ambient + diffuse, 1.0);
//
//    vertexOut.color = float4(in.texCoord[0], in.texCoord[1], 0.5, 1.0);
    
    return vertexOut;
}

fragment float4 simpleFragmentShader(VertexOut interpolated [[stage_in]]) {
    return interpolated.color;
}

struct LineVertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
};

vertex VertexOut lineVertexShader(
    LineVertexIn in [[stage_in]],
    const device Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
    const device matrix_float4x4& modelMatrix [[ buffer(BufferIndexModelMatrix) ]]
) {
    VertexOut vertexOut;
    
    float4 position = float4(in.position, 1.0);
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * modelMatrix * position;

    vertexOut.color = float4(1.0, 0.0, 0.0, 1.0);
    
    return vertexOut;
}

