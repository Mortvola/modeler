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
