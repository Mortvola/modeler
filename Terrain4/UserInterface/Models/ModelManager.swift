//
//  ObjectManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/8/23.
//

import SwiftUI

struct ModelManager: View {
    @ObservedObject var objectStore = ObjectStore.shared
    @State var addObject = false
    
    var somethingSelected: Bool {
        objectStore.selectedNode != nil
    }
    
    var body: some View {
        VStack {
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
                .disabled(!somethingSelected)

                Button {
                    Task {
                        try? await ObjectStore.shared.addSkybox()
                    }
                } label: {
                    Text("Add Skybox")
                }
                .buttonStyle(.bordered)
                .disabled(ObjectStore.shared.skybox != nil)

                Spacer()
                
                Button {
                    try? objectStore.addLight()
                } label: {
                    Text("Add Light")
                }
                .buttonStyle(.bordered)
                .disabled(!somethingSelected)
                
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

struct ModelManager_Previews: PreviewProvider {
    static var previews: some View {
        ModelManager()
    }
}
