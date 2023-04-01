//
//  MaterialDetailView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import SwiftUI

struct MaterialDetailView: View {
    var material: MaterialWrapper
    @State var transparent: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    UndoProvider($transparent) { $transparent in
                        CheckBox(checked: $transparent, label: "Transparent")
                            .onChange(of: transparent) { newValue in
                                material.material.transparent = newValue
                            }
                            .onAppear {
                                transparent = material.material.transparent
                            }
                    }
                    Spacer()
                }
                .padding([.top, .bottom], 10)
                switch material {
                case .pbrMaterial(let m):
                    VStack(spacing: 32) {
                        AlbedoView(albedo: m.albedo)
                        
                        NormalsView(normals: m.normals)
                        
                        MetallicView(metallic: m.metallic)
                        
                        RoughnessView(roughness: m.roughness)
                    }
                case .graphMaterial(let m):
                    GraphMaterialView(material: m)
                case .billboardMaterial(let m):
                    BillboardMaterialView(material: m)
                default:
                    EmptyView()
                }
            }
        }
    }
}

//struct MaterialDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MaterialDetailView(material: Material())
//    }
//}
