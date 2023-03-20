//
//  MetallicView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import SwiftUI

struct MetallicView: View {
    @ObservedObject var material: PbrMaterial
    @State private var useSimple = true
    @State private var metallic = Float(1.0)

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Metalness")
                Spacer()
            }
            VStack {
                HStack {
                    Text("Map:")
                    Text(material.metallic.map)
                    Spacer()
                    OpenFileButton(image: "photo") { url in
                        material.metallic.map = url
                    }
                }
                HStack {
                    UndoProvider($useSimple) { $value in
                        CheckBox(checked: $value, label: "Simple")
                    }
                    Spacer()
                }
                UndoProvider($metallic) { $value in
                    NumericField(value: $value)
                }
            }
            .padding(.leading, 8)
        }
        .onChange(of: useSimple) { newUseSimple in
            material.metallic.useSimple = newUseSimple
        }
        .onAppear {
            useSimple = material.metallic.useSimple
        }
        .onChange(of: metallic) { newMetallic in
            material.setSimpleMetallic(newMetallic)
        }
    }
}

//struct MetallicView_Previews: PreviewProvider {
//    static var previews: some View {
//        MetallicView(material: Material())
//    }
//}
