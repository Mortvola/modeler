//
//  MaterialDescriptor.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

class MaterialDescriptor {
    var id: UUID

    var name = ""
    
    var albedo: AlbedoLayer
    var normals: NormalsLayer
    var metallic: MetallicLayer
    var roughness: RoughnessLayer
    
    init() {
        self.id = UUID()
        
        self.albedo = AlbedoLayer()
        self.normals = NormalsLayer()
        self.metallic = MetallicLayer()
        self.roughness = RoughnessLayer()
    }
}
