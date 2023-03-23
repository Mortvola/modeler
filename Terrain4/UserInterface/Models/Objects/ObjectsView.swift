//
//  ObjectsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct ObjectsView: View {
    @ObservedObject var model: Model
    @Binding var selectedItem: TreeNode?
    
    var body: some View {
        ForEach($model.objects, id: \.id) { $object in
            ModelTreeListItem(node: object, selectedItem: $selectedItem)
        }

        ForEach($model.lights, id: \.id) { $light in
            ModelTreeListItem(node: TreeNode(light: light), selectedItem: $selectedItem)
        }
    }
}

struct ObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsView(model: Model(), selectedItem: .constant(nil))
    }
}
