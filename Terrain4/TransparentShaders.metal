//
//  TransparentShaders.metal
//  Terrain4
//
//  Created by Richard Shields on 4/2/23.
//

#include <metal_stdlib>
#import "CommonTypes.h"

using namespace metal;

kernel void initTransparentFragmentStore
(
    imageblock<TransparentFragmentValues, imageblock_layout_explicit> blockData,
    ushort2 localThreadID[[thread_position_in_threadgroup]]
)
{
    threadgroup_imageblock TransparentFragmentValues* fragmentValues = blockData.data(localThreadID);
    for (short i = 0; i < kNumLayers; ++i)
    {
        fragmentValues->colors[i] = half4(0.0h);
        fragmentValues->depths[i] = half(INFINITY);
    }
}

TransparentFragmentStore processTransparent
(
    float4 color,
    float4 position,
    TransparentFragmentValues fragmentValues [[imageblock_data]]
)
{
    TransparentFragmentStore out;

    half4 finalColor = half4(color);
    finalColor.xyz *= finalColor.w;

    // Get the fragment distance from the camera.
    half depth = position.z / position.w;

    // Insert the transparent fragment values in order of depth, discarding
    // the farthest fragments after the `colors` and `depths` are full.
    for (short i = 0; i < kNumLayers; ++i)
    {
        half layerDepth = fragmentValues.depths[i];
        half4 layerColor = fragmentValues.colors[i];

        bool insert = (depth <= layerDepth);
        fragmentValues.colors[i] = insert ? finalColor : layerColor;
        fragmentValues.depths[i] = insert ? depth : layerDepth;

        finalColor = insert ? layerColor : finalColor;
        depth = insert ? layerDepth : depth;
    }
    
    out.values = fragmentValues;

    return out;
}

typedef struct
{
    float4  position   [[position]];
} ColorInOut;

/// A vertex function that generates a full-screen quad pass.
vertex ColorInOut quadPassVertex(uint vid[[vertex_id]])
{
    ColorInOut out;

    float4 position;
    position.x = (vid == 2) ? 3.0 : -1.0;
    position.y = (vid == 0) ? -3.0 : 1.0;
    position.zw = 1.0;

    out.position = position;
    return out;
}

/// Blends the opaque fragment in the color attachment with the transparent fragments in the image block
/// structures.
///
/// This shader runs after `processTransparentFragment` inserts the transparent fragments in order of depth from back to front.
fragment half4 blendFragments
(
    TransparentFragmentValues fragmentValues     [[imageblock_data]],
    half4                     forwardOpaqueColor [[color(0), raster_order_group(0)]]
 )
{
    half4 out;

    // Start with the opaque fragment from the color attachment.
    out.rgb = forwardOpaqueColor.rgb;

    // Blend the transparent fragments in the image block from the back to front,
    // which is equivalent to the farthest layer moving toward the nearest layer.
    for (short i = kNumLayers - 1; i >= 0; --i)
    {
        half4 layerColor = fragmentValues.colors[i];
        out.rgb = layerColor.rgb + (1.0h - layerColor.a) * out.xyz;
    }

    out.a = 1.0;

    return out;
}
