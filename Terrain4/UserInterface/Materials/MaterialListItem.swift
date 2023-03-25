//
//  MaterialListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import SwiftUI

struct MaterialListItem: View {
    var material: MaterialEntry
    @State private var name: String = ""
    @Binding var selectedItem: MaterialEntry?
    
    var body: some View {
        ListItemBase(text: $name, isSelected: selectedItem == material) {
            selectedItem = material
        }
            .onAppear {
                name = material.material.name
            }
            .onChange(of: name) { newName in
                material.material.name = name
            }
    }
}

//struct MaterialListItem_Previews: PreviewProvider {
//    static var previews: some View {
//        MaterialListItem(material: Material())
//    }
//}
