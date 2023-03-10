//
//  TopBorder.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/28/22.
//

import SwiftUI

struct Border: ViewModifier {
    var edge: Alignment

    func body(content: Content) -> some View {
        content
            .overlay(Rectangle().frame(width: nil, height: 1, alignment: edge).foregroundColor(.gray), alignment: edge)
    }
}

extension View {
    func border(edge: Alignment) -> some View {
        modifier(Border(edge: edge))
    }
}

struct TopBorder_Previews: PreviewProvider {
    static var previews: some View {
        Text("Test").border(edge: .top)
    }
}
