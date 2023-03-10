//
//  ObjectManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/8/23.
//

import SwiftUI

struct ObjectManager: View {
    @StateObject var lights = Lights.shared
    @ObservedObject var objectStore = ObjectStore.shared
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
            HStack {
                Spacer()
                Button {
                    objectStore.addModel()
                } label: {
                    Text("Add Model")
                }
                .buttonStyle(.bordered)
                Spacer()
                Button {
                    addObject = true
                } label: {
                    Text("Add Object")
                }
                .buttonStyle(.bordered)
                .disabled(objectStore.selectedModel == nil)
                Spacer()
            }
            ModelsView()
            Spacer();
        }
        .sheet(isPresented: $addObject) {
            AddObject(isOpen: $addObject)
        }
    }
}

struct ObjectManager_Previews: PreviewProvider {
    static var previews: some View {
        ObjectManager()
    }
}
