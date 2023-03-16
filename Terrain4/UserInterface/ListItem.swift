//
//  ListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ListItem: View {
    @Binding var text: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ListItemField(text: $text)
        }
        .buttonStyle(.plain)
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(text: .constant("Test")) {
            print("It workedd!")
        }
    }
}
