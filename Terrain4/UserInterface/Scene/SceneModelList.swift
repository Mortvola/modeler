//
//  SceneModelList.swift
//  Terrain4
//
//  Created by Richard Shields on 3/29/23.
//

import SwiftUI

struct SceneModelList: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var file: SceneDocument
    @ObservedObject var scene: TheScene
    @Binding var selectedItem: SceneModel?
    @Binding var isEditMode: EditMode

    var body: some View {
        List {
            ForEach(scene.models) { model in
                SceneListItem(sceneModel: model, selectedItem: $selectedItem)
            }
            .onMove { indexSet, destination in
                scene.models.move(fromOffsets: indexSet, toOffset: destination)
                undoManager?.registerUndo(withTarget: file) { _ in
                    print("undo")
                }
            }
            .onDelete { indexSet in
                scene.models.remove(atOffsets: indexSet)
                undoManager?.registerUndo(withTarget: file) { _ in
                    print("undo")
                }
            }
        }
        .environment(\.editMode, $isEditMode)
    }
}

//struct SceneModelList_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneModelList()
//    }
//}
