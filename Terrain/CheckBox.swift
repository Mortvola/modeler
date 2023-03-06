//
//  CheckBox.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import SwiftUI

struct CheckBox: View {
    @Binding var checked: Bool
    var label: String
    
    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? Color(.systemBlue) : Color.secondary)
            .onTapGesture {
                self.checked.toggle()
            }
        Text(label)
    }
}

struct CheckBox_Previews: PreviewProvider {
    static var previews: some View {
        CheckBox(checked: .constant(true), label: "Test Label")
    }
}
