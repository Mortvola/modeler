//
//  AlbedoView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import SwiftUI

struct AlbedoView: View {
    @ObservedObject var material: Material
    @State private var useSimple = true
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Albedo")
                Spacer()
            }
            VStack {
                HStack {
                    Text("Map")
                    TextField("", text: $material.albedo)
                    OpenFileButton(image: "photo") { url in
                        material.albedo = url
                    }
                }
                HStack {
                    CheckBox(checked: $useSimple, label: "Simple")
                    Spacer()
                }
            }
            .padding(.leading, 8)
        }
        .onChange(of: useSimple) { newUseSimple in
            material.materialEntry?.material.albedo.useSimple = newUseSimple
        }
        .onAppear {
            useSimple = material.materialEntry?.material.albedo.useSimple ?? true
        }
    }
}

struct AlbedoView_Previews: PreviewProvider {
    static var previews: some View {
        AlbedoView(material: Material())
    }
}
