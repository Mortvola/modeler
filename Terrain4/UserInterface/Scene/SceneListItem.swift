//
//  SceneListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/27/23.
//

import SwiftUI

struct SceneListItem: View {
    var sceneModel: SceneModel
    @State private var name: String = ""
    @Binding var selectedItem: SceneModel?
    
    var body: some View {
        ListItemBase(text: $name, isSelected: selectedItem == sceneModel) {
            selectedItem = sceneModel
        }
            .onAppear {
                name = sceneModel.name
            }
            .onChange(of: name) { newName in
                sceneModel.name = name
            }
    }
}

//struct SceneListItem_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneListItem()
//    }
//}
