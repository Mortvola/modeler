//
//  MaterialListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import SwiftUI

struct MaterialListItem: View {
    @ObservedObject var material: PbrMaterial
    @ObservedObject var materialStore = MaterialManager.shared
    @Binding var selectedMaterial: PbrMaterial?
    
    var body: some View {
        ListItem(node: material) {
            selectedMaterial = material
        }
    }
}

//struct MaterialListItem_Previews: PreviewProvider {
//    static var previews: some View {
//        MaterialListItem(material: Material())
//    }
//}
