//
//  ContentView.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var lights = Lights.shared
    @State var red: Double = 0
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

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
                VStack(spacing: 4) {
                    HStack {
                        Text("Light Intensity:")
                        Spacer();
                    }
                    VStack(spacing: 4) {
                        HStack {
                            Text("Red:")
                            TextField("Red", value: $lights.red, formatter: formatter)
                        }
                        HStack {
                            Text("Green:")
                            TextField("Green", value: $lights.green, formatter: formatter)
                            Spacer()
                        }
                        HStack {
                            Text("Blue:")
                            TextField("Blue", value: $lights.blue, formatter: formatter)
                            Spacer()
                        }
                    }
                    .padding(.leading, 4)
                }
                .padding(.top, 8)
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
