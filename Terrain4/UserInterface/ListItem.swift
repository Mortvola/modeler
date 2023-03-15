//
//  ListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ListItem: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ListItemLabel(label: label)
        }
        .buttonStyle(.plain)
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(label: "Test") {
            print("It workedd!")
        }
    }
}
