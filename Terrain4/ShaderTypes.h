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
    BufferIndexFrameConstants = 2,
    BufferIndexModelMatrix = 3,
    BufferIndexNodeUniforms = 4,
    BufferIndexMaterialUniforms = 5,
    BufferIndexCascadeIndex = 7,
    BufferIndexReduction = 8,
    BufferIndexFinalReduction = 9,
    BufferIndexShadowCascadeMatrices = 10
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

//const int MAX_CASCADES = 4;
// static constexpr constant short MAX_CASCADES = 4;

typedef struct {
    matrix_float4x4 viewProjectionMatrix[4];
} ShadowCascadeMatrices;

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 invProjectionMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 inverseViewMatrix;
    vector_float3 cameraPos;
    float fovy;
    float aspect;
    vector_float3 lightVector;
    vector_float3 lightColor;
    bool cascadeDebug;
} FrameConstants;

typedef struct {
    vector_float3 position;
    vector_float3 intensity;
} Lights;

typedef struct {
    vector_float4 color;
    int numberOfLights;
    Lights lights[4];
} NodeUniforms;

typedef struct {
    vector_float3 albedo;
    vector_float3 normals;
    float metallic;
    float roughness;
} PbrMaterialUniforms;

typedef struct {
    vector_float4 color;
    float size;
    matrix_float4x4 modelMatrix;
} PointUniforms;

typedef struct {
    vector_float4 color;
    vector_float2 scale;
} BillboardUniforms;

typedef struct {
    uint8_t argOffset[8];
    float arg[8];
} GraphUniforms;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float3x3 normalMatrix;
} ModelMatrixUniforms;

typedef struct {
    vector_float3 min;
    vector_float3 max;
} MinMax;

static
#ifdef __METAL_VERSION__
constexpr constant
#endif
int kTileWidth = 16;

static
#ifdef __METAL_VERSION__
constexpr constant
#endif
int kTileHeight = 16;

#endif /* ShaderTypes_h */

