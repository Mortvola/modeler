//
//  MaterialsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import SwiftUI

struct MaterialsView: View {
    @ObservedObject var materialStore = MaterialManager.shared
    @State var hidden = false
    @State private var selectedMaterial: PbrMaterial?
    
    var materialList: [PbrMaterial] {
        materialStore.materials.compactMap { entry in
            if entry.key == nil {
                return nil
            }
            
            return entry.value.material
        }
    }

    var body: some View {
        VStack {
            Button {
                Task {
                    try? await materialStore.addMaterial()
                }
            } label: {
                Text("Add Material")
            }
            .buttonStyle(.bordered)
            List {
                ForEach(materialList, id: \.id) { material in
                    MaterialListItem(material: material, selectedMaterial: $selectedMaterial)
                        .selected(selected: material == selectedMaterial)
                }
            }
            if let material = selectedMaterial, !hidden {
                MaterialDetailView(material: material)
                    .onChange(of: selectedMaterial) { _ in
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
