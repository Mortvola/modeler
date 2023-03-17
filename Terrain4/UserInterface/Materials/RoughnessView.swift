//
//  RoughnessView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import SwiftUI

struct RoughnessView: View {
    @ObservedObject var material: PbrMaterial
    @State private var useSimple = true
    @State private var roughness = Float(1.0)

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Roughness")
                Spacer()
            }
            VStack {
                HStack {
                    Text("Map:")
                    Text(material.roughness.map)
                    OpenFileButton(image: "photo") { url in
                        material.roughness.map = url
                    }
                }
                HStack {
                    CheckBox(checked: $useSimple, label: "Simple")
                    Spacer()
                }
                NumericField(value: $roughness)
            }
            .padding(.leading, 8)
        }
        .onChange(of: useSimple) { newUseSimple in
            material.roughness.useSimple = newUseSimple
        }
        .onAppear {
            useSimple = material.roughness.useSimple
        }
        .onChange(of: roughness) { newRoughness in
            material.setSimpleRoughness(newRoughness)
        }
    }
}

//struct RoughnessView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoughnessView(material: Material())
//    }
//}
