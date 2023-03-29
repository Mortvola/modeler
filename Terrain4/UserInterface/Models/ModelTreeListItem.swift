//
//  ModelTreeListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/20/23.
//

import SwiftUI

struct ModelTreeListItem: View {
    var node: TreeNode
    @State var name: String = ""
    @Binding var selectedItem: TreeNode?

    var body: some View {
        HStack {
            VisibleButton(node: node, selectedItem: $selectedItem)
            ListItemBase(text: $name, isSelected: selectedItem == node) {
                selectedItem = node
            }
        }
        .onAppear {
            name = node.name
        }
        .onChange(of: name) { newName in
            node.name = name
        }
    }
}

struct ModelTreeListItem_Previews: PreviewProvider {
    static var previews: some View {
        ModelTreeListItem(node: TreeNode(model: Model()), selectedItem: .constant(nil))
    }
}
