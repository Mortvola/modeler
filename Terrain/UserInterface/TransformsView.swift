//
//  TransformsView.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct TransformsView: View {
    @ObservedObject var object: Model
    @Environment(\.editMode) private var editMode

    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Transforms")
                Spacer()
                EditButton()
            }
            List {
                ForEach($object.transforms) { $transform in
                    TransformView(transform: $transform)
                        .labelsHidden()
                }
                .onMove(perform: isEditing ? { indexSet, destination in
                    object.transforms.move(fromOffsets: indexSet, toOffset: destination)
                }: nil)
                .onDelete(perform: isEditing ? { indexSet in
                    print("Before: \(object.transforms.count)")
                    object.transforms.remove(atOffsets: indexSet)
                    print("After: \(object.transforms.count)")
                } : nil)
                
                if isEditing {
                    Button {
                        object.transforms.append(Transform())
                    } label: {
                        Text("Add Transform")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}

struct TransformsView_Previews: PreviewProvider {
    static var previews: some View {
        TransformsView(object: Model())
    }
}
