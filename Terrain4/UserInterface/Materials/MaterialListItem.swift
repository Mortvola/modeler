//
//  MaterialListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import SwiftUI

struct MaterialListItem: View {
    @ObservedObject var material: Material
    @ObservedObject var materialStore = MaterialStore.shared
    
    var body: some View {
        ListItem(label: material.name) {
            if materialStore.selectedMaterial == material {
                materialStore.selectedMaterial = nil
            }
            else {
                materialStore.selectedMaterial = material
            }
        }
    }
}

struct MaterialListItem_Previews: PreviewProvider {
    static var previews: some View {
        MaterialListItem(material: Material())
    }
}
