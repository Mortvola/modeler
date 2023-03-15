//
//  Selected.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import SwiftUI

struct Selected: ViewModifier {
    var selected: Bool

    func body(content: Content) -> some View {
        content
            .padding(4)
            .overlay {
                selected
                ?
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.blue, lineWidth: 1)
                : nil
            }
    }
}

extension View {
    func selected(selected: Bool) -> some View {
        modifier(Selected(selected: selected))
    }
}
