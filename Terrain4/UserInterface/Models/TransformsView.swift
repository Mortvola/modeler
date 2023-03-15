//
//  TransformsView.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct TransformsView: View {
    @ObservedObject var model: Model
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
                ForEach(model.transforms) { transform in
                    TransformView(transform: transform)
                }
                .onMove(perform: isEditing ? { indexSet, destination in
                    model.transforms.move(fromOffsets: indexSet, toOffset: destination)
                }: nil)
                .onDelete(perform: isEditing ? { indexSet in
                    model.transforms.remove(atOffsets: indexSet)
                } : nil)
                
                if isEditing {
                    Button {
                        model.transforms.append(Transform())
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
        TransformsView(model: Model())
    }
}
