//
//  MaterialsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import SwiftUI

struct MaterialsView: View {
    @ObservedObject var materialManager = Renderer.shared.materialManager
    @State var hidden = false
    @State private var selectedMaterial: MaterialWrapper?
    
    var materialList: [MaterialWrapper] {
        materialManager.materials.compactMap { entry in
            entry.value
        }
    }

    var body: some View {
        GeometryReader { gp in
            VStack {
                Menu("Add Material") {
                    Button("PBR Pipeline") {
                        materialManager.addMaterial(PbrMaterial())
                    }
                    Button("Graph Pipeline") {
                        materialManager.addMaterial(GraphMaterial())
                    }
                    Button("Billboard Pipeline") {
                        materialManager.addMaterial(BillboardMaterial())
                    }
                }
                .buttonStyle(.bordered)
                List {
                    ForEach(materialList, id: \.material.id) { material in
                        MaterialListItem(material: material, selectedItem: $selectedMaterial)
                    }
                }
                .frame(height: gp.size.height / 2)
                .border(edge: .bottom)
                
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
}

struct MaterialsView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialsView()
    }
}
