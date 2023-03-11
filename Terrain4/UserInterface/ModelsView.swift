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
                            objectStore.selectModel(nil);
                        }
                        else {
                            objectStore.selectModel(model);
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
            
            if let model = objectStore.selectedModel {
                ModelDetailsView(model: model)
            }
            else if let object = objectStore.selectedObject {
                ObjectDetailsView(object: object)
            }
            else if let light = objectStore.selectedLight {
                LightDetailsView(light: light)
            }
        }
    }
}

struct ModelsView_Previews: PreviewProvider {
    static var previews: some View {
        ModelsView()
    }
}
