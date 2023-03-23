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
        if selected {
            RoundedRectangle(cornerRadius: 5)
                .stroke(.blue, lineWidth: 1)
                .background {
                    Color(.systemBlue)
                }
                .overlay {
                    content
                        .foregroundColor(.white)
                }
        }
        else {
            content
        }
    }
}

extension View {
    func selected(selected: Bool) -> some View {
        modifier(Selected(selected: selected))
    }
}
