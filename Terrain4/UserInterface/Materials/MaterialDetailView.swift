//
//  MaterialDetailView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import SwiftUI

struct MaterialDetailView: View {
    var material: MaterialEntry
    
    var body: some View {
        switch material {
        case .pbrMaterial(let m):
            VStack(spacing: 32) {
                AlbedoView(material: m)
                
                NormalsView(material: m)
                
                MetallicView(material: m)
                
                RoughnessView(material: m)
            }
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
