//
//  NormalsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import SwiftUI

struct NormalsView: View {
    @ObservedObject var material: PbrMaterial
    @State private var useSimple = true

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Normals")
                Spacer()
            }
            VStack {
                HStack {
                    Text("Map:")
                    Text(material.normals.map)
                    Spacer()
                    OpenFileButton(image: "photo") { url in
                        material.normals.map = url
                    }
                }
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
            material.normals.useSimple = newUseSimple
        }
        .onAppear {
            useSimple = material.normals.useSimple
        }
    }
}

//struct NormalsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NormalsView(material: Material())
//    }
//}
