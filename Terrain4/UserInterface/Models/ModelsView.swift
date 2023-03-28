//
//  ObjectsView.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct ModelsView: View {
    @ObservedObject var objectStore: ObjectStore
    @ObservedObject var model: Model
    @Binding var selectedItem: TreeNode?

    var body: some View {
        VStack {
            List {
                ObjectsView(model: model, selectedItem: $selectedItem)
                    .padding(.leading, 16)
                ModelTreeListItem(node: TreeNode(directionalLight: objectStore.directionalLight), selectedItem: $selectedItem)
            }
            .listStyle(.inset)
        }
    }
}

//struct ModelsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelsView(objectStore: ObjectStore(), selectedItem: .constant(nil))
//    }
//}
