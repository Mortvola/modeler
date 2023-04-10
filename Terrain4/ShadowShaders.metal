//
//  ShadowShaderes.metal
//  Terrain4
//
//  Created by Richard Shields on 3/18/23.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
#import "Utilities.h"
using namespace metal;

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
};

vertex float4 shadowVertexShader
(
    VertexIn in [[stage_in]],
    const device ShadowCascadeMatrices& matrices [[ buffer(BufferIndexShadowCascadeMatrices) ]],
    const device ModelMatrixUniforms *modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    const device int32_t &cascadeIndex [[ buffer(BufferIndexCascadeIndex) ]],
    uint instanceId [[ instance_id ]]
) {
    return matrices.viewProjectionMatrix[cascadeIndex]
        * modelMatrix[instanceId].modelMatrix
        * float4(in.position, 1.0);
}

//struct DepthAccum {
//    float2 min;
//    float2 max;
//};
//
//static constexpr constant short kNumGroups = 32;
//
//using DepthAccumStore = DepthAccum[kNumGroups];
//
//kernel void reduceDepth
//(
//    depth2d<float, access::read> depth [[texture(TextureIndexDepth)]],
//    device float *data [[buffer(0)]],
//    uint2 gpig [[threadgroup_position_in_grid]],
//    uint2 tpig [[thread_position_in_grid]]
//)
//{
////    constexpr sampler shadowSampler(coord::normalized,
////                                    address::clamp_to_edge,
////                                    filter::linear,
////                                    compare_func::greater_equal);
//
//    ulong value = depth.read(tpig); // (shadowSampler, gpig);
//
//    volatile device atomic_ulong *atomicBuffer = (device atomic_ulong *)data;
//
//    atomic_min_explicit(atomicBuffer, value, memory_order_relaxed);
//    atomic_max_explicit(atomicBuffer, value, memory_order_relaxed);
//}

//struct DepthFragmentValues {
//    bool valid [[raster_order_group(0)]];
//    float3 worldPosition [[raster_order_group(0)]];
//    half3 min [[raster_order_group(1)]];
//    half3 max  [[raster_order_group(1)]];
//};

struct DepthFragmentStore {
    float depth [[color(0)]];
};

kernel void initDepthFragmentStore
(
    device atomic_float *data [[buffer(BufferIndexReduction)]],
    device atomic_float *finalBounds [[buffer(BufferIndexFinalReduction)]],
    ushort threadIndex [[thread_index_in_threadgroup]],
    ushort2 tid [[thread_position_in_threadgroup]],
    uint2 tgpig [[threadgroup_position_in_grid]],
    uint2 tgpg [[threadgroups_per_grid]]
)
{
    if (threadIndex == 0) {
        atomic_store_explicit(data + (tgpig[1] * tgpg[0] + tgpig[0]) * 2 + 0, 1.0, memory_order_relaxed);
        atomic_store_explicit(data + (tgpig[1] * tgpg[0] + tgpig[0]) * 2 + 1, 0.0, memory_order_relaxed);
        
        atomic_store_explicit(finalBounds + 0, 0.0, memory_order_relaxed);
        atomic_store_explicit(finalBounds + 1, FLT_MAX, memory_order_relaxed);
    }
}

struct VertexOut {
    float4 position [[position]];
    float worldZ;
//    float color;
};

vertex VertexOut depthReductionVertexShader
(
    VertexIn in [[stage_in]],
    const device FrameConstants& frameConstants [[ buffer(BufferIndexFrameConstants) ]],
    const device ModelMatrixUniforms *modelMatrix [[ buffer(BufferIndexModelMatrix) ]],
    uint instanceId [[ instance_id ]]
) {
    VertexOut out;
    
    float4 view = frameConstants.viewMatrix
        * modelMatrix[instanceId].modelMatrix
    * float4(in.position, 1.0);

    out.position = frameConstants.projectionMatrix * view;
    out.worldZ = view.z;
    
    return out;
}

//vertex VertexOut depthReductionVertexShader2(uint vid[[vertex_id]])
//{
//    VertexOut out;
//
//    float4 position;
//    position.x = (vid == 2) ? 3.0 : -1.0;
//    position.y = (vid == 0) ? -3.0 : 1.0;
//    position.zw = 1.0;
//
//    float colors[3] = {1852 * 4.0 / 2, 0, 3099 * 4.0 / 2};
//    out.position = position;
//    out.color = colors[vid];
//
//    return out;
//}


fragment float depthReductionFragmentShader
(
    VertexOut in [[stage_in]]
) {
    return in.position.z;
//    return in.worldZ;
}

float linearizeDepth(float depth, matrix_float4x4 invProjection) {
    float4 point = {0, 0, depth, 1};
    
    // TODO: we really only need the lower 2x2 portion of this matrix.
    point = invProjection * point;
    
    return point.z / point.w;
}

//constant int kThreadsPerThreadgroup = kTileWidth * kTileHeight;

float2 minMaxDepthBounds(float2 bounds1, float2 bounds2) {
    return float2(min(bounds1.x, bounds2.x), max(bounds1.y, bounds2.y));
}

kernel void reduceDepthFragments
(
    const device FrameConstants& frameConstants [[ buffer(BufferIndexFrameConstants) ]],
    imageblock<DepthFragmentStore> blockData,
    device atomic_uint *data [[buffer(BufferIndexReduction)]],
    ushort qid [[thread_index_in_quadgroup]],
    ushort2 tid [[thread_position_in_threadgroup]],
    uint2 tgpig [[threadgroup_position_in_grid]],
    uint2 tgpg [[threadgroups_per_grid]]
)
{
    // Max, Min
    float2 bounds = {1.0, 0.0};

    for (ushort y = 0; y < 16; y += 8) {
        for (ushort x = 0; x < 16; x += 8) {
            float depth = blockData.read(tid + ushort2(x, y)).depth;
            bounds = minMaxDepthBounds(bounds, float2(depth ? depth : 1, depth));
        }
    }
    
    // Get the min/max of the point below this one by shuffling in the value from thread 2
    bounds = minMaxDepthBounds(bounds, quad_shuffle_down(bounds, 2));
    
    // Get the min/max of the point to the right of this one by shuffling in the value from thread 1 (thread 1
    // will also have the min/max of the point to the right and down (thread 3) because of the shuffle operation above).
    bounds = minMaxDepthBounds(bounds, quad_shuffle_down(bounds, 1));

    if (qid == 0) {
        uint2 uintBounds = as_type<uint2>(bounds);
        atomic_fetch_min_explicit(data + (tgpig[1] * tgpg[0] + tgpig[0]) * 2 + 0, uintBounds.x, memory_order_relaxed);
        atomic_fetch_max_explicit(data + (tgpig[1] * tgpg[0] + tgpig[0]) * 2 + 1, uintBounds.y, memory_order_relaxed);
    }
}

kernel void minMaxDepthBoundsFinalize
(
 const device FrameConstants& frameConstants [[ buffer(BufferIndexFrameConstants) ]],
 const device atomic_uint *data [[ buffer(BufferIndexReduction) ]],
 device ShadowCascadeMatrices& shadowCascadeMatrices [[ buffer(BufferIndexShadowCascadeMatrices) ]],
 device uint *finalBounds [[ buffer(BufferIndexFinalReduction) ]],
 ushort2 tid [[thread_position_in_threadgroup]],
 ushort qid [[thread_index_in_quadgroup]],
 uint2 tgpig [[threadgroup_position_in_grid]],
 uint2 tgpg [[threadgroups_per_grid]]
)
{
    if (tgpig.x == 0 && tgpig.y == 0) {
        float2 bounds = {1, 0};
        
        for (uint y = 0; y < tgpg.y; ++y) {
            for (uint x = 0; x < tgpg.x; ++x) {
                float minimum = as_type<float>(atomic_load_explicit(data + (y * tgpg.x + x) * 2 + 0, memory_order_relaxed));
                float maximum = as_type<float>(atomic_load_explicit(data + (y * tgpg.x + x) * 2 + 1, memory_order_relaxed));

                bounds = minMaxDepthBounds(bounds, float2(minimum, maximum));
            }
        }

        bounds = float2(linearizeDepth(bounds.x, frameConstants.invProjectionMatrix),
                        linearizeDepth(bounds.y, frameConstants.invProjectionMatrix));

        uint2 uintBounds = as_type<uint2>(bounds);

        finalBounds[0] = uintBounds.x;
        finalBounds[1] = uintBounds.y;
        
        int numberOfCascades = 4;
        float splits[5];
        
        computeFrustumSplits(bounds, numberOfCascades, splits);
        
        for (int i = 0; i < numberOfCascades; ++i) {
            float4x4 inverseProjection = inverseProjectionMatrix(frameConstants.fovy, frameConstants.aspect, splits[i], splits[i + 1]);
            
            float4x4 inverseViewProjection =  frameConstants.inverseViewMatrix * inverseProjection;

            float4 frustumCorners[8];

            transformNdcBoundsToWorldSpace(inverseViewProjection, frustumCorners);

            calculateViewProjectionMatrix(frustumCorners, frameConstants.lightVector, true, shadowCascadeMatrices.viewProjectionMatrix[i]);
        }
    }
}
