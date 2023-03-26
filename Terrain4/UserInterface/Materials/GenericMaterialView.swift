//
//  GenericMaterialView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/26/23.
//

import SwiftUI

struct GenericMaterialView: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var file: SceneDocument
    @ObservedObject var material: SimpleMaterial
    
    var body: some View {
        List {
            ForEach(material.layers, id: \.id) { layer in
                HStack {
                    switch layer {
                    case .color:
                        EmptyView()
                    case .texture(let l):
                        TextureLayerView(layer: l)
                    case .monoColor:
                        EmptyView()
                    }
                    Button {
                        material.deleteLayer(id: layer.id)
                        undoManager?.registerUndo(withTarget: file) { _ in
                            print("undo")
                        }
                    } label: {
                        Image(systemName: "minus")
                    }
                }
            }
            VStack {
                Menu("Add Layer") {
                    Button {
                        material.layers.append(LayerWrapper.texture(Texture()))
                    } label: {
                        Text("Texture")
                    }
                    Button {
                        material.layers.append(LayerWrapper.color(Vec4(1, 1, 1, 1)))
                    } label: {
                        Text("Color")
                    }
                }
                Spacer()
            }
        }
        .listStyle(.plain)
    }
}

//struct GenericMaterialView_Previews: PreviewProvider {
//    static var previews: some View {
//        GenericMaterialView()
//    }
//}
