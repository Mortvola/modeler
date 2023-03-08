//
//  Utilities.swift
//  Terrain
//
//  Created by Richard Shields on 2/23/23.
//

import Foundation

func latLngToTerrainTile(
  _ lat: Double, _ lng: Double, _ dimension: Int
) -> (Int, Int) {
  // Add 180 to convert coordinates to positive values for convenience.
    let x = Int(floor(((lng + 180.0) * 3600.0) / Double(dimension)))
    let y = Int(floor(((lat + 180.0) * 3600.0) / Double(dimension)))

  return (x, y);
}

func terrainTileToLatLng(_ x: Double, _ y: Double, _ dimension: Int) -> LatLng {
    let lng = (x * Double(dimension)) / 3600.0 - 180.0;
    let lat = (y * Double(dimension)) / 3600.0 - 180.0;

  return LatLng(lat, lng);
}

func latLngToMercator(lat: Double, lng: Double) -> (Double, Double) {
  let latRad = degreesToRadians(lat);
  let lngRad = degreesToRadians(lng);

  let equatorialRadius = 6378137.0;
  let a = equatorialRadius;
  let f = 1 / 298.257223563;
  let b = a * (1 - f); // WGS84 semi-minor axis
    let e = (1 - pow(b, 2) / pow(a, 2)).squareRoot() // ellipsoid eccentricity

  let sinLatRad = sin(latRad);

  let c = ((1 - e * sinLatRad) / (1 + e * sinLatRad));

  let x = lngRad * a;
  let y = log(((1 + sinLatRad) / (1 - sinLatRad)) * pow(c, e)) * (a / 2);

  return (x, y)
}

func bilinearInterpolation(
  _ f00: Float, _ f10: Float, _ f01: Float, _ f11: Float, _ x: Float, _ y: Float
) -> Float {
  let oneMinusX = 1 - x
  let oneMinusY = 1 - y
  return (f00 * oneMinusX * oneMinusY + f10 * x * oneMinusY + f01 * oneMinusX * y + f11 * x * y)
}
