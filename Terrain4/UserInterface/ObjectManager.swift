//
//  ObjectManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/8/23.
//

import SwiftUI

struct ObjectManager: View {
    @ObservedObject var objectStore = ObjectStore.shared
    @State var addObject = false
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var somethingSelected: Bool {
        objectStore.selectedModel != nil || objectStore.selectedObject != nil || objectStore.selectedLight != nil
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

struct ObjectManager_Previews: PreviewProvider {
    static var previews: some View {
        ObjectManager()
    }
}
