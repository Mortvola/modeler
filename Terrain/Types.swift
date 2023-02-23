//
//  Types.swift
//  Terrain
//
//  Created by Richard Shields on 2/23/23.
//

import Foundation

struct LatLng {
    var lat: Double
    var lng: Double
    
    init(_ lat: Double, _ lng: Double) {
        self.lat = lat
        self.lng = lng
    }
}

struct ObjectProps: Decodable {
  var type: String
  var points: [Double]
  var normals: [Double]
  var indices: [Int]
};

struct TerrainTileProps: Decodable {
  var xDimension: Double
  var yDimension: Double
  var ele: [[Double]]
  var objects: [ObjectProps]
};
