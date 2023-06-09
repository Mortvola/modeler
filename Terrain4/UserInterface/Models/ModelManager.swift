//
//  ObjectManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/8/23.
//

import SwiftUI

struct ModelManager: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var file: SceneDocument
    @ObservedObject var objectStore: ObjectStore
    @State private var addObject = false
    @State private var selectedItem: TreeNode? = nil
    @State private var addObjectTo: Model? = nil
    @State var hidden = false

    var body: some View {
        GeometryReader { gp in
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button {
                            selectedItem = objectStore.addModel()
                            undoManager?.registerUndo(withTarget: file) { _ in
                                print("undo")
                            }
                        } label: {
                            Text("Add Model")
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button {
                            addObjectTo = selectedItem?.getNearestModel()
                            addObject = true
                        } label: {
                            Text("Add Object")
                        }
                        .buttonStyle(.bordered)
                        .disabled(selectedItem == nil)
                        
                        Button {
                            Task {
                                try? await objectStore.addSkybox()
                            }
                        } label: {
                            Text("Add Skybox")
                        }
                        .buttonStyle(.bordered)
                        .disabled(objectStore.skybox != nil)
                        
                        Spacer()
                        
                        Button {
                            if let model = selectedItem?.getNearestModel() {
                                let light = model.addLight()
                                
                                selectedItem = TreeNode(light: light)
                                objectStore.lights.append(light)
                            }
                        } label: {
                            Text("Add Light")
                        }
                        .buttonStyle(.bordered)
                        .disabled(selectedItem == nil)
                        
                        Spacer()
                    }
                    ModelsView(objectStore: objectStore, selectedItem: $selectedItem)
                }
                .frame(height: gp.size.height / 2)
                .border(edge: .bottom)
                VStack {
                    if (!hidden) {
                        switch selectedItem?.content {
                        case .model(let m):
                            ModelDetailsView(model: m)
                                .onChange(of: selectedItem) { _ in
                                    hidden = true
                                    Task {
                                        hidden = false
                                    }
                                }
                        case .mesh(let o):
                            ObjectDetailsView(object: o)
                                .onChange(of: selectedItem) { _ in
                                    hidden = true
                                    Task {
                                        hidden = false
                                    }
                                }
                        case .light(let l):
                            LightDetailsView(light: l)
                                .onChange(of: selectedItem) { _ in
                                    hidden = true
                                    Task {
                                        hidden = false
                                    }
                                }
                        case .directionalLight(let d):
                            DirectionalLightView(light: d)
                                .onChange(of: selectedItem) { _ in
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
                Spacer();
            }
            .sheet(isPresented: $addObject) {
                AddObject(undoManager: undoManager, isOpen: $addObject, selectedItem: $selectedItem, model: $addObjectTo)
            }
            .environmentObject(objectStore)
        }
    }
}

struct ModelManager_Previews: PreviewProvider {
    static var previews: some View {
        ModelManager(objectStore: ObjectStore())
    }
}
