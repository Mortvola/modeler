//
//  CommonTypes.m
//  Terrain4
//
//  Created by Richard Shields on 4/2/23.
//
#ifndef CommonTypes_h
#define CommonTypes_h

/// The number of transparent geometry layers that the app stores in image block memory.
/// Each layer consumes tile memory and increases the value of the pipeline's `imageBlockSampleLength` property.
static constexpr constant short kNumLayers = 4;

/// Stores color and depth values of transparent fragments.
/// The `processTransparentFragment` shader adds color values from transparent geometries in
/// ascending depth order.
/// Then, the `blendFragments` shader blends the color values for each fragment in descending
/// depth order after the app draws all the transparent geometry.
struct TransparentFragmentValues
{
    // Store the color of the transparent fragment.
    // Use a packed data type to reduce the size of the explicit ImageBlock.
    metal::rgba8unorm<half4> colors [[raster_order_group(0)]] [kNumLayers];

    // An array of transparent fragment distances from the camera.
    half depths              [[raster_order_group(0)]] [kNumLayers];
};

/// Stores the color values for multiple fragments in image block memory.
/// The `[[imageblock_data]]` attribute tells Metal to store `values` in the GPU's
/// image block memory, which preserves its data for an entire render pass.
struct TransparentFragmentStore
{
    TransparentFragmentValues values [[imageblock_data]];
};

#endif /* CommonTypes_h */

