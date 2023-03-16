//
//  MetallicView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import SwiftUI

struct MetallicView: View {
    @ObservedObject var material: Material
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
                    Text("Map")
                    TextField("", text: $material.metalness)
                    OpenFileButton(image: "photo") { url in
                        material.metalness = url
                    }
                }
                HStack {
                    CheckBox(checked: $useSimple, label: "Simple")
                    Spacer()
                }
                NumericField(value: $metallic)
            }
            .padding(.leading, 8)
        }
        .onChange(of: useSimple) { newUseSimple in
            material.materialEntry?.material.metallic.useSimple = newUseSimple
        }
        .onAppear {
            useSimple = material.materialEntry?.material.metallic.useSimple ?? true
        }
        .onChange(of: metallic) { newMetallic in
            material.materialEntry?.material.setSimpleMetallic(newMetallic)
        }
    }
}

struct MetallicView_Previews: PreviewProvider {
    static var previews: some View {
        MetallicView(material: Material())
    }
}
