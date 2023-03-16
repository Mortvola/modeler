//
//  MaterialsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import SwiftUI

struct MaterialsView: View {
//    @State var openFile = false
    @ObservedObject var materialStore = MaterialStore.shared
    @State var hidden = false
    
    var body: some View {
        VStack {
            Button {
                materialStore.addMaterial()
            } label: {
                Text("Add Material")
            }
            .buttonStyle(.bordered)
            List {
                ForEach(materialStore.materials) { material in
                    MaterialListItem(material: material)
                        .selected(selected: material == materialStore.selectedMaterial)
                }
            }
            if let material = materialStore.selectedMaterial, !hidden {
                MaterialDetailView(material: material)
                    .onChange(of: materialStore.selectedMaterial) { _ in
                        hidden = true
                        Task {
                            hidden = false
                        }
                    }
            }
        }
    }
}

struct MaterialsView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialsView()
    }
}
