//
//  ListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ListItem: View {
    @ObservedObject var node: Node
    let action: () -> Void
    
    var body: some View {
        HStack {
            Button {
                action()
            } label: {
                ListItemField(text: $node.name)
            }
            .buttonStyle(.plain)
            Spacer()
            Button {
                node.disabled.toggle()
            } label: {
                node.disabled ? Image(systemName: "eye.slash") : Image(systemName: "eye")
            }
        }
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(node: Node(name: "test")) {
            print("It workedd!")
        }
    }
}
