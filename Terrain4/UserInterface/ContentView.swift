//
//  ContentView.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            ObjectManager()
                .padding(0)
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
        .padding(0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
