//
//  ListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ListItem<T>: View where T: Item {
    @ObservedObject var item: T
    @Binding var selectedItem: T?
    
    var body: some View {
        ListItemBase(text: $item.name, isSelected: selectedItem == item) {
            selectedItem = item
        }
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(item: Item(name: "test"), selectedItem: .constant(nil))
    }
}
