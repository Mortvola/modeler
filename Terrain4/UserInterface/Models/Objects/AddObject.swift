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
    @Binding var selectedItem: TreeNode?
    @Binding var model: Model?
    
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
                            let object = try? await model?.addObject(type: type)
                            
                            if let object = object {
                                selectedItem = TreeNode(object: object)
                            }
                            
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

//struct AddObject_Previews: PreviewProvider {
//    static var previews: some View {
//        AddObject(isOpen: .constant(true), selected)
//    }
//}
