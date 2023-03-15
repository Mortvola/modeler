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
}

struct ContentView: View {
    @State private var tabSelection: TabSelection = .objects
    
    var body: some View {
        NavigationSplitView {
            TabView(selection: $tabSelection) {
                ModelManager()
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
                    .tag(TabSelection.animators)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Open") {
                        Task {
                            try await ObjectStore.shared.open()
                        }
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Save") {
                        ObjectStore.shared.save()
                    }
                }
            }
        } detail: {
            ZStack {
                RenderView()
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
