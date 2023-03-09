//
//  ObjectManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/8/23.
//

import SwiftUI

struct ObjectManager: View {
    @StateObject var lights = Lights.shared
    @State var openFile = false
    @State var addObject = false
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
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
            Button {
                addObject = true
            } label: {
                Text("Add Object")
            }
            .buttonStyle(.bordered)
            Button {
                openFile = true
            } label: {
                Text("Import Texture")
            }
            .buttonStyle(.bordered)
            ObjectsView()
            Spacer();
        }
        .padding()
        .fileImporter(isPresented: $openFile, allowedContentTypes: [.image]) { result in
            try? TextureStore.shared.addTexture(url: result.get())
        }
        .sheet(isPresented: $addObject) {
            AddObject(isOpen: $addObject)
        }
        .padding(0)
    }
}

struct ObjectManager_Previews: PreviewProvider {
    static var previews: some View {
        ObjectManager()
    }
}
