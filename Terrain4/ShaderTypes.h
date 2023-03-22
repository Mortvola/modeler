//
//  ShaderTypes.h
//  Terrain
//
//  Created by Richard Shields on 2/23/23.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
typedef metal::int32_t EnumBackingType;
#else
#import <Foundation/Foundation.h>
typedef NSInteger EnumBackingType;
#endif

#include <simd/simd.h>

typedef NS_ENUM(EnumBackingType, BufferIndex) {
    BufferIndexMeshPositions = 0,
    BufferIndexNormals = 1,
    BufferIndexUniforms = 2,
    BufferIndexNodeUniforms = 3
};

typedef NS_ENUM(EnumBackingType, VertexAttribute) {
    VertexAttributePosition = 0,
    VertexAttributeTexcoord = 1,
    VertexAttributeNormal = 2,
    VertexAttributeTangent = 3,
    VertexAttributeColor = 4
};

typedef NS_ENUM(EnumBackingType, TextureIndex) {
    TextureIndexColor = 0,
    TextureIndexNormals = 1,
    TextureIndexMetallic = 2,
    TextureIndexRoughness = 3,
    TextureIndexAo = 4,
    TextureIndexDepth = 5
};

typedef NS_ENUM(EnumBackingType, SamplerIndex) {
    SamplerIndexSampler = 0,
};

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 lightProjectionViewMatrix;
    vector_float3 lightVector;
    vector_float3 lightColor;
    vector_float3 cameraPos;
} FrameUniforms;

typedef struct {
    vector_float3 position;
    vector_float3 intensity;
} Lights;

typedef struct {
    vector_float4 color;
    matrix_float4x4 modelMatrix;
    matrix_float3x3 normalMatrix;
    vector_float3 albedo;
    vector_float3 normals;
    float metallic;
    float roughness;
    int numberOfLights;
    Lights lights[4];
} NodeUniforms;

//typedef struct {
//    vector_float3 albedo;
//    float metallic;
//    float roughness;
//    float ao;
//} PbrValues;

#endif /* ShaderTypes_h */

