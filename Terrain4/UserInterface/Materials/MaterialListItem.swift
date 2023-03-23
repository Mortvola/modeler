//
//  MaterialListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import SwiftUI

struct MaterialListItem: View {
    @ObservedObject var material: PbrMaterial
    @Binding var selectedItem: PbrMaterial?
    
    var body: some View {
        ListItem(item: material, selectedItem: $selectedItem)
    }
}

//struct MaterialListItem_Previews: PreviewProvider {
//    static var previews: some View {
//        MaterialListItem(material: Material())
//    }
//}
