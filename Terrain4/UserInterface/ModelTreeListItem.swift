//
//  ModelTreeListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/20/23.
//

import SwiftUI

struct ModelTreeListItem: View {
    @ObservedObject var node: Node
    let action: () -> Void

    var body: some View {
        HStack {
            ListItem(item: node, action: action)
            Spacer()
            Button {
                node.disabled.toggle()
            } label: {
                node.disabled ? Image(systemName: "eye.slash") : Image(systemName: "eye")
            }
        }
    }
}

struct ModelTreeListItem_Previews: PreviewProvider {
    static var previews: some View {
        ModelTreeListItem(node: Node(name: "test")) {
            print("It workedd!")
        }
    }
}
