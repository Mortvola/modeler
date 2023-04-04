//
//  ContentView.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import SwiftUI
import ModelIO
import MetalKit

enum TabSelection {
    case objects
    case materials
    case textures
    case scene
    case settings
}

struct ContentView: View {
    var file: SceneDocument
    @State private var tabSelection: TabSelection = .objects
    @State var openPicker = false
    @State var openSave = false
    @State var selectedModel: Model? = nil
    @State var importObj = false
    
    var body: some View {
        NavigationSplitView {
            TabView(selection: $tabSelection) {
                ModelManager(objectStore: file.objectStore, selectedModel: $selectedModel)
                    .tabItem {
                        Label("Objects", systemImage: "circle.grid.2x2")
                    }
                    .tag(TabSelection.objects)

                MaterialsView()
                    .tabItem {
                        Label("Matrials", systemImage: "line.3.crossed.swirl.circle.fill")
                    }
                    .tag(TabSelection.materials)
                TexturesView()
                    .tabItem {
                        Label("Textures", systemImage: "line.3.crossed.swirl.circle.fill")
                    }
                    .tag(TabSelection.textures)

                SceneView(objectStore: file.objectStore)
                    .tabItem {
                        Label("Scene", systemImage: "video")
                    }
                    .tag(TabSelection.scene)
                
                SettingsView(objectStore: file.objectStore)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(TabSelection.settings)
            }
            .padding()
            .toolbarRole(.automatic)
            .environmentObject(file)
        } detail: {
            ZStack {
                RenderView(file: file)
                VStack {
                    Spacer()
                    HStack {
                        Text("Test").foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                ImportObj { url in
                    if let url = url {
                        let node = file.objectStore.addModel()
                        
                        switch node.content {
                        case .model(let model):
                            Task {
                                selectedModel = model
                                _ = try? await model.importObj(url: url)
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }
        .onChange(of: tabSelection) { newTabSelection in
            switch Renderer.shared.currentViewMode {
            case .scene:
                if newTabSelection == .objects {
                    Renderer.shared.setViewMode(viewMode: .model)
                }
            case .model:
                if newTabSelection == .scene {
                    Renderer.shared.setViewMode(viewMode: .scene)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedModel) { newModel in
            Renderer.shared.setSelectedModel(model: newModel)
        }
        .environmentObject(file)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(file: SceneDocument())
//    }
//}
