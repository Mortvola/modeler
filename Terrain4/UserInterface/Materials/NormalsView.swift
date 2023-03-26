//
//  NormalsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import SwiftUI

struct NormalsView: View {
    @ObservedObject var normals: NormalsLayer
    @State private var useSimple = true

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Normals")
                Spacer()
            }
            VStack {
                TextureMapView(layer: normals)
                HStack {
                    UndoProvider($useSimple) { $value in
                        CheckBox(checked: $value, label: "Simple")
                    }
                    Spacer()
                }
            }
            .padding(.leading, 8)
        }
        .onChange(of: useSimple) { newUseSimple in
            normals.useSimple = newUseSimple
        }
        .onAppear {
            useSimple = normals.useSimple
        }
    }
}

//struct NormalsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NormalsView(material: Material())
//    }
//}
