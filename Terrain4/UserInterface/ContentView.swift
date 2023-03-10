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
    @State var tabSelection: TabSelection = .objects
    
    var body: some View {
        NavigationSplitView {
            TabView(selection: $tabSelection) {
                ObjectManager()
                    .tabItem {
                        Label("Objects", systemImage: "circle.grid.2x2")
                    }
                    .tag(TabSelection.objects)

                AnimatorsView()
                    .tabItem {
                        Label("Animators", systemImage: "arrow.clockwise.circle")
                    }
                    .tag(TabSelection.animators)

                TexturesView()
                    .tabItem {
                        Label("Textures", systemImage: "line.3.crossed.swirl.circle.fill")
                    }
                    .tag(TabSelection.animators)
            }
            .padding()
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
