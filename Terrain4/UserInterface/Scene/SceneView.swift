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
    @State var hidden = false

    var body: some View {
        GeometryReader { gp in
            VStack {
                VStack {
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
                    List {
                        ForEach(objectStore.scene.models) { model in
                            SceneListItem(sceneModel: model, selectedItem: $selectedItem)
                        }
                    }
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
