//
//  MaterialDetailView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import SwiftUI

struct MaterialDetailView: View {
    @ObservedObject var material: PbrMaterial
    
    var body: some View {
        VStack(spacing: 32) {
            AlbedoView(material: material)
            
            NormalsView(material: material)
            
            MetallicView(material: material)
            
            RoughnessView(material: material)            
        }
    }
}

//struct MaterialDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MaterialDetailView(material: Material())
//    }
//}
