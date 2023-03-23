//
//  VisibleButton.swift
//  Terrain4
//
//  Created by Richard Shields on 3/22/23.
//

import SwiftUI

struct VisibleButton<T>: View where T: TreeNode {
    @ObservedObject var node: T
    @Binding var selectedItem: T?
    
    var body: some View {
        HStack {
            node.disabled ? Image(systemName: "eye.slash") : Image(systemName: "eye")
        }
        .onTapGesture {
            node.disabled.toggle()
            selectedItem = node
        }
    }
}

struct VisibleButton_Previews: PreviewProvider {
    static var previews: some View {
        VisibleButton(node: TreeNode(model: Model()), selectedItem: .constant(nil))
    }
}
