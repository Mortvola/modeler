//
//  Utilities.h
//  Terrain4
//
//  Created by Richard Shields on 4/9/23.
//
#ifndef Utilities_h
#define Utilities_h

void computeFrustumSplits(float2 depthBounds, int numberOfCascades, float splits[]);

void transformNdcBoundsToWorldSpace(metal::float4x4 inverseViewProjectionMatrix, float4 frustum[8]);

void calculateViewProjectionMatrix(float4 cameraFrustum[], float3 direction, bool tightBounds, device metal::float4x4 &matrix);

metal::float4x4 inverseProjectionMatrix(float fovy, float aspect, float nearZ, float farZ);

#endif // Utilities_h
