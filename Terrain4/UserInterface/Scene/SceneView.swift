//
//  SceneView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/27/23.
//

import SwiftUI

struct SceneView: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var file: SceneDocument
    @ObservedObject var objectStore: ObjectStore
    @State private var selectedItem: SceneModel? = nil
    @State private var hidden = false
    @State private var isEditMode: EditMode = .inactive

    var body: some View {
        GeometryReader { gp in
            VStack {
                VStack {
                    HStack {
                        Menu("Add Model Instance") {
                            ForEach(objectStore.models) { modelWrapper in
                                switch modelWrapper.content {
                                case .model(let m):
                                    Button {
                                        objectStore.scene.models.append(SceneModel(model: m))
                                        undoManager?.registerUndo(withTarget: file) { _ in
                                            print("undo")
                                        }
                                    } label: {
                                        Text(m.name)
                                    }
                                default:
                                    EmptyView()
                                }
                            }
                        }
                        Button {
                            if isEditMode == .active {
                                isEditMode = .inactive
                            }
                            else {
                                isEditMode = .active
                            }
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                    SceneModelList(scene: objectStore.scene, selectedItem: $selectedItem, isEditMode: $isEditMode)
                    Spacer()
                }
                .frame(height: gp.size.height / 2)
                .border(edge: .bottom)
                if let selectedItem = selectedItem, !hidden {
                    ModelSceneDetails(model: selectedItem)
                        .onChange(of: selectedItem) { _ in
                            hidden = true
                            Task {
                                hidden = false
                            }
                        }
                }
                Spacer()
            }
        }
    }
}

//struct SceneView_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneView()
//    }
//}
