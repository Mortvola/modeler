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
    BufferIndexModelMatrix = 3,
    BufferIndexNormalMatrix = 4,
    BufferIndexPbrValues = 5,
    BufferIndexLightPos = 6
};

typedef NS_ENUM(EnumBackingType, VertexAttribute) {
    VertexAttributePosition = 0,
    VertexAttributeTexcoord = 1,
    VertexAttributeNormal = 2,
    VertexAttributeTangent = 3,
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
    vector_float3 lightVector;
    vector_float3 lightColor;
    vector_float3 cameraPos;
    matrix_float4x4 lightViewProjectionMatrix;
} Uniforms;

typedef struct {
    int numberOfLights;
    vector_float3 position[4];
    vector_float3 intensity[4];
} Lights;

//typedef struct {
//    vector_float3 albedo;
//    float metallic;
//    float roughness;
//    float ao;
//} PbrValues;

#endif /* ShaderTypes_h */

