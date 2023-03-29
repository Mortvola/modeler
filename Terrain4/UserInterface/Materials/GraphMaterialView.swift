//
//  GenericMaterialView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/26/23.
//

import SwiftUI

struct GraphMaterialView: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var file: SceneDocument
    @ObservedObject var material: GraphMaterial
    
    var body: some View {
        List {
            ForEach(material.layers, id: \.id) { layer in
                HStack {
                    switch layer {
                    case .color:
                        EmptyView()
                    case .texture(let l):
                        TextureNodeView(node: l)
                    case .add(let n):
                        AddNodeView(node: n)
                    }
                    Spacer()
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
                        material.layers.append(GraphNodeWrapper.texture(GraphNodeTexture()))
                    } label: {
                        Text("Texture")
                    }
                    Button {
                        material.layers.append(GraphNodeWrapper.color(GraphNodeColor()))
                    } label: {
                        Text("Color")
                    }
                    Button {
                        material.layers.append(GraphNodeWrapper.add(GraphNodeAdd()))
                    } label: {
                        Text("Add")
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
