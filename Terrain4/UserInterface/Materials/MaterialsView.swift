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
    @State private var selectedMaterial: MaterialEntry?
    
    var materialList: [MaterialEntry] {
        materialManager.materials.compactMap { entry in
            entry.value
        }
    }

    var body: some View {
        ZStack {
            VStack {
                Menu("Add Material") {
                    Button("PBR Material") {
                        let material = PbrMaterial()
                        materialManager.addMaterial(pbrMaterial: material)
                    }
                    Button("Simple Material") {
                        let material = SimpleMaterial()
                        materialManager.addMaterial(simpleMaterial: material)
                    }
                }
                .buttonStyle(.bordered)
                List {
                    ForEach(materialList, id: \.material.id) { material in
                        MaterialListItem(material: material, selectedItem: $selectedMaterial)
                    }
                }
                if let material = selectedMaterial, !hidden {
                    switch material {
                    case .pbrMaterial(let m):
                        MaterialDetailView(material: m)
                            .onChange(of: selectedMaterial) { _ in
                                hidden = true
                                Task {
                                    hidden = false
                                }
                            }
                    default:
                        EmptyView()
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
