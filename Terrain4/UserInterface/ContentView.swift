//
//  ContentView.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import SwiftUI

enum TabSelection {
    case objects
    case animators
    case materials
    case textures
}

struct ContentView: View {
    var file: SceneDocument
    @State private var tabSelection: TabSelection = .objects
    @State var openPicker = false
    @State var openSave = false
    
    var body: some View {
        NavigationSplitView {
            TabView(selection: $tabSelection) {
                ModelManager(objectStore: file.objectStore)
                    .tabItem {
                        Label("Objects", systemImage: "circle.grid.2x2")
                    }
                    .tag(TabSelection.objects)

                AnimatorsView()
                    .tabItem {
                        Label("Animators", systemImage: "arrow.clockwise.circle")
                    }
                    .tag(TabSelection.animators)

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
            }
            .padding()
            .toolbarRole(.automatic)
            .environmentObject(file)
//            .toolbar {
//                ToolbarItem(placement: .automatic) {
//                    Button("Open") {
//                        openPicker = true
//                    }
//                }
//                ToolbarItem(placement: .automatic) {
//                    Button("Save") {
//                        if SceneDocument.shared.bookmark == nil {
//                            openSave = true
//                        } else {
////                            ObjectStore.shared.save()
//                        }
//                    }
//                }
//            }
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
        .toolbar(.hidden)
        .environmentObject(file)
//        .fileImporter(isPresented: $openPicker, allowedContentTypes: [.sceneDocument]) { result in
//            if let url = try? result.get() {
//                Task {
//                    try? await SceneDocument.shared.open(url: url)
//                }
//            }
//        }
//        .fileExporter(isPresented: $openSave, document: SceneDocument.shared, contentType: .sceneDocument, defaultFilename: nil) { result in
//            if let url = try? result.get() {
//                SceneDocument.shared.bookmark = try? url.bookmarkData(options: .withSecurityScope)
//            }
//        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(file: SceneDocument())
//    }
//}
