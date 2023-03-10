//
//  ObjectsView.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct ModelsView: View {
    @ObservedObject var objectStore = ObjectStore.shared
    @State var editedObject: Model? = nil
    
    var body: some View {
        VStack {
            List {
                ForEach(objectStore.models, id: \.id) { model in
                    Button {
                        if objectStore.selectedModel == model {
                            objectStore.selectedModel = nil
                        }
                        else {
                            objectStore.selectedModel = model
                        }
                    } label: {
                        HStack {
                            Text(model.name)
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .background(objectStore.selectedModel == model ? Color(.lightGray) : Color(.white))
                    ObjectsView(model: model)
                        .padding(.leading, 16)
                }
            }
            
            if let selection = objectStore.selectedModel {
                ModelDetailsView(model: selection)
            }
        }
    }
}

struct ModelsView_Previews: PreviewProvider {
    static var previews: some View {
        ModelsView()
    }
}
