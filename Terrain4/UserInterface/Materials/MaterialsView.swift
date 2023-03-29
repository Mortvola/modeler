//
//  MaterialsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import SwiftUI

struct MaterialsView: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var file: SceneDocument
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
                        undoManager?.registerUndo(withTarget: file) { _ in
                            print("undo")
                        }
                    }
                    Button("Graph Pipeline") {
                        materialManager.addMaterial(GraphMaterial())
                        undoManager?.registerUndo(withTarget: file) { _ in
                            print("undo")
                        }
                    }
                    Button("Billboard Pipeline") {
                        materialManager.addMaterial(BillboardMaterial())
                        undoManager?.registerUndo(withTarget: file) { _ in
                            print("undo")
                        }
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
