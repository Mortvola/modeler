//
//  ObjectMaterialView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ObjectMaterialView: View {
    @ObservedObject var object: RenderObject
    @State var material: Material?
    
    var body: some View {
        HStack {
            Picker("Type", selection: $material) {
                Text("None").tag(nil as Material?)
                ForEach(MaterialStore.shared.materials) { material in
                    Text(material.name).tag(material as Material?)
                }
            }
            .labelsHidden()
            .onChange(of: material) { newMaterial in
                Task {
                    try? await object.setMaterial(newMaterial: newMaterial)
                }
            }
            Spacer()
        }
        .onAppear {
            material = object.material
        }
    }
}

struct ObjectMaterialView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectMaterialView(object: RenderObject(model: Model()))
    }
}
