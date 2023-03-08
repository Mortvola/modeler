//
//  Sun.swift
//  Terrain
//
//  Created by Richard Shields on 3/1/23.
//

import Foundation

struct SunAngles {
    var elevationAngle: Double
    var azimuth: Double
}

func getSunLightVector (day: Int, hour: Double, latitude: Double) -> vec3 {
    let latitudeRadians = degreesToRadians(latitude)

    // Add 10 to slide the year window so that the year ends on Dec 21 (winter solstice)
    let radiansAroundSun = (.pi * 2 / 365.0) * (Double(day) + 10.0)
    let declination = degreesToRadians(-23.5) * cos(radiansAroundSun)

    let radiansPerHour = .pi * 2 / 24.0
    let hourAngle = radiansPerHour * (hour - 12.0)

    let elevationAngle = asin(
        sin(declination) * sin(latitudeRadians) +
        cos(declination) * cos(latitudeRadians) * cos(hourAngle)
    )

    let v =   min(max((
        sin(declination) * cos(latitudeRadians) -
        cos(declination) * sin(latitudeRadians) * cos(hourAngle)
    ) / cos(elevationAngle), -1), 1)

    var azimuth = acos(v)

    if (hourAngle >= 0) {
        azimuth = 2 * .pi - azimuth
    }

    return -(vec3(0, 0, 1)
        .rotateX(Float(-elevationAngle))
        .rotateY(Float(azimuth)))
    
//    return normalize(vec3(0, -1, 1));
}

