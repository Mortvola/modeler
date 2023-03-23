//
//  ObjectMaterialView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ObjectMaterialView: View {
    @ObservedObject var object: RenderObject
    @State var materialId: UUID?
    
    var materialList: [PbrMaterial] {
        Renderer.shared.pipelineManager!.pbrPipeline.materials.compactMap { entry in
            if entry.key == nil {
                return nil
            }
            
            return entry.value.material
        }
    }

    var body: some View {
        Text("Materials")
//        HStack {
//            Picker("Type", selection: $materialId) {
//                Text("None").tag(nil as UUID?)
//                ForEach(materialList, id: \.id) { material in
//                    Text(material.name).tag(material.id as UUID?)
//                }
//            }
//            .labelsHidden()
//            .onChange(of: materialId) { newMaterialId in
//                object.setMaterial(materialId: newMaterialId)
//            }
//            Spacer()
//        }
//        .onAppear {
//            materialId = object.material?.id
//        }
    }
}

struct ObjectMaterialView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectMaterialView(object: RenderObject(model: Model()))
    }
}
