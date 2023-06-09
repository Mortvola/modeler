//
//  MaterialDetailView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import SwiftUI

struct MaterialDetailView: View {
    var material: MaterialWrapper
    
    var body: some View {
        switch material {
        case .pbrMaterial(let m):
            VStack(spacing: 32) {
                AlbedoView(albedo: m.albedo)
                
                NormalsView(normals: m.normals)
                
                MetallicView(metallic: m.metallic)
                
                RoughnessView(roughness: m.roughness)
            }
        case .simpleMaterial(let m):
            GenericMaterialView(material: m)
        default:
            EmptyView()
        }
    }
}

//struct MaterialDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MaterialDetailView(material: Material())
//    }
//}
