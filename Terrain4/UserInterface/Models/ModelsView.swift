//
//  ObjectsView.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct ModelsView: View {
    @ObservedObject var objectStore: ObjectStore
    @State var editedObject: Model? = nil
    @State var hidden = false
    
    var body: some View {
        VStack {
            List {
                ForEach($objectStore.models, id: \.id) { $model in
                    ModelTreeListItem(node: model) {
                        objectStore.selectModel(model);
                    }
                    .selected(selected: objectStore.selectedNode == SelectedNode.model(model))
                    ObjectsView(objectStore: objectStore, model: model)
                        .padding(.leading, 16)
                }
                ModelTreeListItem(node: objectStore.directionalLight) {
                    objectStore.selectDirectionalLight()
                }
                .selected(selected: objectStore.selectedNode == SelectedNode.directLight(objectStore.directionalLight))
            }
            .listStyle(.inset)

            if (!hidden) {
                switch objectStore.selectedNode {
                case .model(let m):
                    ModelDetailsView(model: m)
                        .onChange(of: objectStore.selectedNode) { _ in
                            hidden = true
                            Task {
                                hidden = false
                            }
                        }
                case .object(let o):
                    ObjectDetailsView(object: o)
                        .onChange(of: objectStore.selectedNode) { _ in
                            hidden = true
                            Task {
                                hidden = false
                            }
                        }
                case .light(let l):
                    LightDetailsView(light: l)
                        .onChange(of: objectStore.selectedNode) { _ in
                            hidden = true
                            Task {
                                hidden = false
                            }
                        }
                case .directLight(let d):
                    DirectionalLightView(light: d)
                        .onChange(of: objectStore.selectedNode) { _ in
                            hidden = true
                            Task {
                                hidden = false
                            }
                        }
                default:
                    EmptyView()
                }
            }
        }
    }
}

struct ModelsView_Previews: PreviewProvider {
    static var previews: some View {
        ModelsView(objectStore: ObjectStore())
    }
}
