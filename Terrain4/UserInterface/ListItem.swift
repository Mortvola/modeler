//
//  ListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ListItem: View {
    @ObservedObject var item: Item
    let action: () -> Void
    
    var body: some View {
        HStack {
            Button {
                action()
            } label: {
                ListItemField(text: $item.name)
            }
            .buttonStyle(.plain)
        }
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(item: Item(name: "test")) {
            print("It workedd!")
        }
    }
}
