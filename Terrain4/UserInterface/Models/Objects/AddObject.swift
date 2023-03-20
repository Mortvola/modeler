//
//  AddObject.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct AddObject: View {
    var undoManager: UndoManager?
    @EnvironmentObject private var file: SceneDocument
    @State private var type = ObjectStore.ObjectType.sphere
    @Binding var isOpen: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Type", selection: $type) {
                    ForEach(ObjectStore.ObjectType.allCases, id: \.rawValue) { value in
                        Text(value.name).tag(value)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Add Object")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isOpen = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            try? await file.objectStore.addObject(type: type)
                            print("\(undoManager.debugDescription)")
                            undoManager?.registerUndo(withTarget: file) { _ in
                                print("undo add object")
                            }
                            isOpen = false
                        }
                    }
                }
            }
        }
    }
}

struct AddObject_Previews: PreviewProvider {
    static var previews: some View {
        AddObject(isOpen: .constant(true))
    }
}
