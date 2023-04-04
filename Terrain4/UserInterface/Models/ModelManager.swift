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
    @State private var hidden = false
    @Binding var selectedModel: Model?
    @State private var rename = false
    @State private var renameValue = ""

    var modelList: [Model] {
        objectStore.models.compactMap { node in
            switch node.content {
            case .model(let m):
                return m
            default:
                return nil
            }
        }
    }
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
                            Text("New Model")
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button {
                            addObjectTo = selectedModel
                            addObject = true
                        } label: {
                            Text("Add Object")
                        }
                        .buttonStyle(.bordered)
                        .disabled(selectedModel == nil)
                        
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
                                objectStore.scene.lights.append(light)
                            }
                        } label: {
                            Text("Add Light")
                        }
                        .buttonStyle(.bordered)
                        .disabled(selectedItem == nil)
                        
                        Spacer()
                    }
                    HStack {
                        if rename {
                            Spacer()
                            UndoProvider($renameValue) { $renameValue in
                                TextField("", text: $renameValue)
                                    .onChange(of: renameValue) { newValue in
                                        selectedModel?.name = newValue
                                    }
                            }
                            Button {
                                rename = false
                            } label: {
                                Image(systemName: "x.square")
                            }
                            Spacer()
                        }
                        else {
                            Picker("Model", selection: $selectedModel) {
                                Text("None").tag(nil as Model?)
                                ForEach(modelList) { model in
                                    Text(model.name).tag(model as Model?)
                                }
                            }
                            .background {
                                Rectangle().stroke(.black)
                            }
                            
                            Button {
                                rename = true
                                renameValue = selectedModel?.name ?? ""
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .disabled(selectedModel == nil)
                            
                            Button {
                                selectedModel?.center()
                                undoManager?.registerUndo(withTarget: file) { _ in
                                    print("undo")
                                }
                            } label: {
                                Image(systemName: "align.horizontal.center")
                            }
                            .disabled(selectedModel == nil)
                            
                            Button {
                                if let model = selectedModel {
                                    objectStore.deleteModel(model: model)
                                    selectedModel = nil
                                    undoManager?.registerUndo(withTarget: file) { _ in
                                        print("undo")
                                    }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .disabled(selectedModel == nil)
                        }
                    }
                    .padding(.top, 8)
                    if let model = selectedModel {
                        ModelsView(objectStore: objectStore, model: model, selectedItem: $selectedItem)
                    }
                    Spacer()
                }
                .frame(height: gp.size.height / 2)
                .border(edge: .bottom)
                VStack {
                    if (!hidden) {
                        switch selectedItem?.content {
                        case .model(let m):
                            TransformsView(model: m)
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
                AddObject(undoManager: undoManager, isOpen: $addObject, selectedItem: $selectedItem, model: $selectedModel)
            }
            .environmentObject(objectStore)
        }
    }
}

//struct ModelManager_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelManager(objectStore: ObjectStore())
//    }
//}
