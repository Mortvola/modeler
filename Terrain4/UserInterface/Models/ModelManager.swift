//
//  ObjectManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/8/23.
//

import SwiftUI

struct ModelManager: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var file: SceneDocument
    @ObservedObject var objectStore: ObjectStore
    @State var addObject = false
    
    var somethingSelected: Bool {
        objectStore.selectedNode != nil
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()

                Button {
                    objectStore.addModel()
                    undoManager?.registerUndo(withTarget: file) { _ in
                        print("undo")
                    }
                } label: {
                    Text("Add Model")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    addObject = true
                } label: {
                    Text("Add Object")
                }
                .buttonStyle(.bordered)
                .disabled(!somethingSelected)

                Button {
                    Task {
                        try? await objectStore.addSkybox()
                    }
                } label: {
                    Text("Add Skybox")
                }
                .buttonStyle(.bordered)
                .disabled(objectStore.skybox != nil)

                Spacer()

                Button {
                    try? objectStore.addLight()
                } label: {
                    Text("Add Light")
                }
                .buttonStyle(.bordered)
                .disabled(!somethingSelected)

                Spacer()
            }
            ModelsView(objectStore: objectStore)
            Spacer();
        }
        .sheet(isPresented: $addObject) {
            AddObject(undoManager: undoManager, isOpen: $addObject)
        }
    }
}

struct ModelManager_Previews: PreviewProvider {
    static var previews: some View {
        ModelManager(objectStore: ObjectStore())
    }
}
