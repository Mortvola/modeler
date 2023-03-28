//
//  TerrainTile.swift
//  Terrain
//
//  Created by Richard Shields on 2/25/23.
//

import Foundation
import Http
import Metal
import MetalKit

class TerrainTile: Model {
    let x: Int
    let y: Int
    let dimension: Int
    var xDimension: Float = 1.0
    var yDimension: Float = 1.0
    var scale = Vec3(1.0, 1.0, 1.0)
    var elevation: [[Float]] = []
    
    init(x: Int, y: Int, dimension: Int) {
        self.x = x
        self.y = y
        self.dimension = dimension
        
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        self.x = 0
        self.y = 0
        self.dimension = 0
        
        try super.init(from: decoder)
    }

    func load() async throws {
//        if let response: Http.Response<TerrainTileProps> = try? await Http.get(path: "/tile/terrain3d/\(dimension)/\(x)/\(y)") {
//            if let data = response.data {
//                self.xDimension = data.xDimension
//                self.yDimension = data.yDimension
//                self.elevation = data.ele
//
//                for object in data.objects {
//                    switch (object.type) {
//                    case "triangles":
//                        let material = try await MaterialManager.shared.addMaterial(device: self.device, view: self.view, material: Material())
//                        let object: RenderObject = TriangleMesh(device: self.device, points: object.points, normals: object.normals, indices: object.indices, model: self)
//
//                        material.objects.append(object)
//                        self.objects.append(object)
//                        break
//
//                    case "line":
//                        let material = try await MaterialManager.shared.addMaterial(device: self.device, view: self.view, material: Material())
//
//                        let object: RenderObject = Line(device: self.device, points: object.points, model: self)
//
//                        material.objects.append(object)
//                        self.objects.append(object)
//
//                        break
//                    default:
//                        break
//                    }
//                }
//            }
//        }
    }
    
    func setScale(scale: Float) {
//        self.scale = Vec3(scale, 1.0, scale)
//        // if (this.photo) {
//        //   this.photo.setScale(scale)
//        // }
//        self.makeModelMatrix();
    }
    
    func getElevation(x: Float, y: Float) -> Float {
        if self.elevation.count > 0 {
            let pointX = (x / self.xDimension + 0.5) * Float(self.elevation[0].count - 1)
            let pointY = (y / self.yDimension + 0.5) * Float(self.elevation.count - 1)
            
            let x1 = Int(pointX)
            let y1 = Int(pointY)
            
            let x2 = pointX - Float(x1)
            let y2 = pointY - Float(y1)
            
            if self.elevation.count > y1 && self.elevation[y1].count > x1 {
                return bilinearInterpolation(
                    self.elevation[y1][x1],
                    self.elevation[y1][x1 + 1],
                    self.elevation[y1 + 1][x1],
                    self.elevation[y1 + 1][x1 + 1],
                    x2,
                    y2
                )
            }
        }
        
        return 0;
    }
}
