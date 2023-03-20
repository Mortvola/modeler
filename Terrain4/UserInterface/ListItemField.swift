//
//  ListItemLabel.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ListItemField: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            UndoProvider($text) { $value in
                TextField("", text: $value)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

struct ListItemField_Previews: PreviewProvider {
    static var previews: some View {
        ListItemField(text: .constant("Test"))
    }
}
