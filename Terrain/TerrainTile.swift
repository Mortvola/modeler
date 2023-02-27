//
//  TerrainTile.swift
//  Terrain
//
//  Created by Richard Shields on 2/25/23.
//

import Foundation
import Http

class TerrainTile {
    let renderer: Renderer
    let x: Int
    let y: Int
    let dimension: Int
    var xDimension: Float = 1.0
    var yDimension: Float = 1.0
    var scale = vec3(1.0, 1.0, 1.0)
    var translate = vec3(0.0, 0.0, 0.0)
    var modelMatrix = matrix4x4_identity()
    var elevation: [[Float]] = []
    var objects: [RenderObject] = []
    
    init(x: Int, y: Int, dimension: Int, renderer: Renderer) {
        self.renderer = renderer
        self.x = x;
        self.y = y;
        self.dimension = dimension
    }
    
    func load() async throws {
        if let response: Http.Response<TerrainTileProps> = try? await Http.get(path: "/tile/terrain3d/\(dimension)/\(x)/\(y)") {
            if let data = response.data {
                self.xDimension = data.xDimension
                self.yDimension = data.yDimension
                self.elevation = data.ele

                try data.objects.forEach { object in
                    switch (object.type) {
                    case "triangles":
                        let material = try MaterialManager.shared.addMaterial(device: renderer.device, view: renderer.view, name: .terrain)
                        let object: RenderObject = TriangleMesh(device: renderer.device, points: object.points, normals: object.normals, indices: object.indices, model: self)
                        
                        material.objects.append(object)
                        self.objects.append(object)
                        break;
                        
                    case "line":
                        let material = try MaterialManager.shared.addMaterial(device: renderer.device, view: renderer.view, name: .line)
                        
                        let object: RenderObject = Line(device: renderer.device, points: object.points, model: self)

                        material.objects.append(object)
                        self.objects.append(object)
                        
                        break;
                    default:
                        break;
                    }
                }
            }
        }
    }
    
    func setScale(scale: Float) {
        self.scale = vec3(scale, 1.0, scale);
        // if (this.photo) {
        //   this.photo.setScale(scale);
        // }
        self.makeModelMatrix();
    }
    
    func setTranslation(x: Float, y: Float, z: Float) {
        self.translate = vec3(x, y, z);
        self.makeModelMatrix();
    }
    
    func makeModelMatrix() {
        self.modelMatrix = matrix4x4_translation(self.translate.x, self.translate.y, self.translate.z)
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
