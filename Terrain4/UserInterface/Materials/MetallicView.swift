//
//  MetallicView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import SwiftUI

struct MetallicView: View {
    @ObservedObject var metallic: MetallicLayer
    @State private var useSimple = true
    @State private var value = Float(1.0)

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Metalness")
                Spacer()
            }
            VStack {
                TextureMapView(layer: metallic)
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
            metallic.useSimple = newUseSimple
        }
        .onAppear {
            value = metallic.value
            useSimple = metallic.useSimple
        }
        .onChange(of: value) { newValue in
            metallic.value = newValue
        }
    }
}

//struct MetallicView_Previews: PreviewProvider {
//    static var previews: some View {
//        MetallicView(material: Material())
//    }
//}
