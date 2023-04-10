//
//  Utilities.metal
//  Terrain4
//
//  Created by Richard Shields on 4/9/23.
//

#include <metal_stdlib>
#include "Utilities.h"
using namespace metal;


float4x4 inverseProjectionMatrix(device const float4x4 &other) {
    float4x4 newMatrix = float4x4();
    
    newMatrix[0][0] = 1 / other[0][0];
    newMatrix[1][1] = 1 / other[1][1];
    newMatrix[2][2] = 0;
    
    newMatrix[2][3] = 1 / other[3][2];
    newMatrix[3][2] = 1 / other[2][3];
    newMatrix[3][3] = -other[2][2] * newMatrix[2][3];
    
    return newMatrix;
}

float4x4 projectionMatrix(float fovy, float aspect, float nearZ, float farZ) {
    float4x4 matrix = float4x4();
    
    float ys = 1 / tan(fovy * 0.5);
    float xs = ys * aspect;
    float zs = farZ / (farZ - nearZ);
    
    matrix[0][0] = xs;
    matrix[1][1] = ys;
    matrix[2][2] = zs;
    matrix[2][3] = 1;
    matrix[3][2] = -nearZ * zs;

    return matrix;
}

float4x4 inverseProjectionMatrix(float fovy, float aspect, float nearZ, float farZ) {
    float4x4 matrix = float4x4();
    
    float ys = tan(fovy * 0.5);
    float xs = ys / aspect;
    float zs = farZ / (farZ - nearZ);
    
    matrix[0][0] = xs;
    matrix[1][1] = ys;
    matrix[2][2] = 0;
    matrix[2][3] = 1 / (-nearZ * zs);
    matrix[3][2] = 1;
    matrix[3][3] = 1 / nearZ;

    return matrix;
}

float4x4 orthographic(float left, float right, float top, float bottom, float near, float far) {
    float width = right - left;
    float height = top - bottom;
    // We divide 2 (the width and height of the NDC cube: -1 to 1 in x and y) by
    // the width or height to scale the x or y coordinate into the -1 to 1 range (after we apply the offset
    // computed below).
    float xScale = 2 / width;
    float yScale = 2 / height;
    float zScale = 1 / (far - near);

    // Adding right and left (or top and bottom) and dividing by 2 gives us the center
    // between the sides of the frustum which is also how far off we are from the NDC origin.
    // We need to also scale this offset so that we are moving it into NDC units.
    float xOffset = (right + left) * 0.5 * xScale;
    float yOffset = (top + bottom) * 0.5 * yScale;
    float zOffset = near * zScale;
    
    return float4x4(
        float4(xScale, 0, 0, 0),
        float4(0, yScale, 0, 0),
        float4(0, 0, zScale, 0),
        float4(-xOffset, -yOffset, -zOffset, 1)
    );
}

void transformNdcBoundsToWorldSpace(float4x4 inverseViewProjectionMatrix, float4 frustum[8]) {
    // Create a box (8 points) in the camera's NDC coordinates and
    // transform the points into world space
    for (int z = 0, i = 0; z <= 1; ++z) {
        for (int y = -1; y <= 1; y += 2) {
            for (int x = -1; x <= 1; x += 2, ++i) {
                float4 point = inverseViewProjectionMatrix * float4(x, y, z, 1.0);
                
                frustum[i] = point / point.w;
            }
        }
    }
}

// Implementation of frustum splitting based on Zhang 2006, "Parallel-Split Shadow Maps for Large-scale Virtual Environments"
void computeFrustumSplits(float2 depthBounds, int numberOfCascades, float splits[]) {
    splits[0] = depthBounds[0];
    
    for (int i = 0; i < numberOfCascades; ++i) {
        float logSplit = pow(depthBounds[0] * (depthBounds[1] / depthBounds[0]), (i + 1.0) / numberOfCascades);
        float uniformSplit = depthBounds[0] + (depthBounds[1] - depthBounds[0]) * (i + 1.0) / numberOfCascades;
        float split = (logSplit + uniformSplit) / 2.0;
                    
        splits[i + 1] = split;
    }
}

float4x4 lookAt(float3 offset, float3 target, float3 up) {
    //    if (
    //      Math.abs(eyex - centerx) < glMatrix.EPSILON &&
    //      Math.abs(eyey - centery) < glMatrix.EPSILON &&
    //      Math.abs(eyez - centerz) < glMatrix.EPSILON
    //    ) {
    //      return identity(out);
    //    }
    float3 z = normalize(target - offset);
    
    float3 x = cross(up, z);
    float lengthSquared = length_squared(x);
    if (lengthSquared == 0) {
        x = float3(0, 0, 0);
    }
    else {
        x /= sqrt(lengthSquared);
    }
    
    float3 y = cross(z, x);
    lengthSquared = length_squared(y);
    if (lengthSquared == 0) {
        y = float3(0, 0, 0);
    }
    else {
        y /= sqrt(lengthSquared);
    }
    
    return float4x4(
        float4(x.x, y.x, z.x, 0),
        float4(x.y, y.y, z.y, 0),
        float4(x.z, y.z, z.z, 0),
        float4(
            -(x.x * offset.x + x.y * offset.y + x.z * offset.z),
            -(y.x * offset.x + y.y * offset.y + y.z * offset.z),
            -(z.x * offset.x + z.y * offset.y + z.z * offset.z),
            1
        )
    );
}

void calculateViewProjectionMatrix(float4 cameraFrustum[], float3 direction, bool tightBounds, device metal::float4x4 &matrix) {
    float4 center = float4(0, 0, 0, 0);
    for (int i = 0; i < 8; ++i) {
        center += cameraFrustum[i];
    }
    
    center /= 8.0;
    
    // Create a transormation matrix to tansform the frustum center
    // to the light space origin
    float3 up = float3(0.0, 1.0, 0.0);
    float3 target = center.xyz + direction;
    float4x4 viewMatrix = lookAt(center.xyz, target, up);
    
    if (tightBounds) {
        float3 minimum = float3(FLT_MAX, FLT_MAX, FLT_MAX);
        float3 maximum = float3(-FLT_MAX, -FLT_MAX, -FLT_MAX);

        // Transform the world coordinates of the camera's fustrum into the
        // viewspace of the light and get the minimum and maximum coordinates.
        // The result will be a fustrum (in view space) that
        // encompasses the camera's fustrum.
        for (int i = 0; i < 8; ++i) {
            float4 trf = viewMatrix * cameraFrustum[i];
            
            minimum.x = min(minimum.x, trf.x);
            minimum.y = min(minimum.y, trf.y);
            minimum.z = min(minimum.z, trf.z);

            maximum.x = max(maximum.x, trf.x);
            maximum.y = max(maximum.y, trf.y);
            maximum.z = max(maximum.z, trf.z);
        }

        matrix = orthographic(minimum.x, maximum.x, maximum.y, minimum.y, minimum.z, maximum.z) * viewMatrix;
    }
}
