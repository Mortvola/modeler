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
    
    var materialList: [PbrMaterial] {
        materialManager.materials.compactMap { entry in
            switch entry.value {
            case .pbrMaterial(let m):
                return m
            default:
                return nil
            }
        }
    }

    var body: some View {
        Text("Materials")
        HStack {
            Picker("Type", selection: $materialId) {
                Text("None").tag(nil as UUID?)
                ForEach(materialList, id: \.id) { material in
                    Text(material.name).tag(material.id as UUID?)
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
