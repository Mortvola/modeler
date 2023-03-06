//
//  ContentView.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var lights = Lights.shared
    
    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    CheckBox(checked: $lights.pointLight, label: "Point Light")
                    Spacer()
                }
                HStack {
                    CheckBox(checked: $lights.rotateObject, label: "Rotate Object")
                    Spacer()
                }
                HStack {
                    CheckBox(checked: $lights.rotateLight, label: "Rotate Light")
                    Spacer()
                }
                Spacer();
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
