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

func getSunAngles (day: Int, hour: Double, latitude: Double) -> SunAngles {
    let latitudeRadians = degreesToRadians(latitude)

    let angle = degreesToRadians((360.0 / 365.0) * (Double(day) + 10.0))
    let declination = degreesToRadians(-23.5 * cos(angle))

    let hourAngle = degreesToRadians(15.0 * (hour - 12.0))

    let elevationAngle = asin(
        sin(declination) * sin(latitudeRadians) +
        cos(declination) * cos(latitudeRadians) * cos(hourAngle)
    )

    let v =   max((
        sin(declination) * cos(latitudeRadians) -
        cos(declination) * sin(latitudeRadians) * cos(hourAngle)
    ) / cos(elevationAngle), -1)

    var azimuth = acos(v)

    if (hourAngle >= 0) {
        azimuth = 2 * .pi - azimuth
    }

    return SunAngles(elevationAngle: elevationAngle, azimuth: azimuth)
}

func getLightVector (elevationAngle: Double, azimuth: Double) -> vec3 {
   vec3(0, 1, 0)
        .rotateX(Float(elevationAngle))
        .rotateZ(Float(-azimuth))
}

