//
//  RoughnessView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import SwiftUI

struct RoughnessView: View {
    @ObservedObject var roughness: RoughnessLayer
    @State private var useSimple = true
    @State private var value = Float(1.0)

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Roughness")
                Spacer()
            }
            VStack {
                TextureMapView(layer: roughness)
                HStack {
                    UndoProvider($useSimple) { $value in
                        CheckBox(checked: $value, label: "Simple")
                    }
                    Spacer()
                }
                UndoProvider($value) { $value in
                    NumericField(value: $value)
                }
            }
            .padding(.leading, 8)
        }
        .onChange(of: useSimple) { newUseSimple in
            roughness.useSimple = newUseSimple
        }
        .onAppear {
            value = roughness.value
            useSimple = roughness.useSimple
        }
        .onChange(of: value) { newValue in
            roughness.value = newValue
        }
    }
}

//struct RoughnessView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoughnessView(material: Material())
//    }
//}
