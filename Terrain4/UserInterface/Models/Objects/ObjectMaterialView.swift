//
//  ObjectMaterialView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ObjectMaterialView: View {
    @ObservedObject var object: RenderObject
    @ObservedObject var materialManager = Renderer.shared.materialManager
    @State var materialId: UUID?
    
    var materialList: [MaterialEntry] {
        materialManager.materials.compactMap { entry in
            entry.value
        }
    }

    var body: some View {
        Text("Materials")
        HStack {
            Picker("Type", selection: $materialId) {
                Text("None").tag(nil as UUID?)
                ForEach(materialList, id: \.material.id) { entry in
                    Text(entry.material.name).tag(entry.material.id as UUID?)
                }
            }
            .labelsHidden()
            .onChange(of: materialId) { newMaterialId in
                object.setMaterial(materialId: newMaterialId)
            }
            Spacer()
        }
        .onAppear {
            materialId = object.material?.id
        }
    }
}

struct ObjectMaterialView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectMaterialView(object: RenderObject(model: Model()))
    }
}
