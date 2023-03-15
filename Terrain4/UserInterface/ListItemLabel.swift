//
//  ListItemLabel.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ListItemLabel: View {
    var label: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

struct ListItemLabel_Previews: PreviewProvider {
    static var previews: some View {
        ListItemLabel(label: "Test")
    }
}
