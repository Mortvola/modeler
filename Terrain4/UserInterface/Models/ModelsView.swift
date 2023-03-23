//
//  ObjectsView.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct ModelsView: View {
    @ObservedObject var objectStore: ObjectStore
    @Binding var selectedItem: TreeNode?

    var body: some View {
        VStack {
            List {
                ForEach($objectStore.models, id: \.id) { $node in
                    ModelTreeListItem(node: node, selectedItem: $selectedItem)
                    switch node.content {
                    case .model(let m):
                        ObjectsView(model: m, selectedItem: $selectedItem)
                            .padding(.leading, 16)
                    case .object:
                        EmptyView()
                    case .light:
                        EmptyView()
                    case .directionalLight:
                        EmptyView()
                    }
                }
                ModelTreeListItem(node: TreeNode(directionalLight: objectStore.directionalLight), selectedItem: $selectedItem)
            }
            .listStyle(.inset)
        }
    }
}

struct ModelsView_Previews: PreviewProvider {
    static var previews: some View {
        ModelsView(objectStore: ObjectStore(), selectedItem: .constant(nil))
    }
}
