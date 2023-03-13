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
    @State var hidden = false
    
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

            if (!hidden) {
                if let model = objectStore.selectedModel {
                    ModelDetailsView(model: model)
                        .onChange(of: objectStore.selectedModel) { _ in
                            hidden = true
                            Task {
                                hidden = false
                            }
                        }
                }
                else if let object = objectStore.selectedObject {
                    ObjectDetailsView(object: object)
                        .onChange(of: objectStore.selectedObject) { _ in
                            hidden = true
                            Task {
                                hidden = false
                            }
                        }
                }
                else if let light = objectStore.selectedLight {
                    LightDetailsView(light: light)
                        .onChange(of: objectStore.selectedLight) { _ in
                            hidden = true
                            Task {
                                hidden = false
                            }
                        }
                }
            }
        }
    }
}

struct ModelsView_Previews: PreviewProvider {
    static var previews: some View {
        ModelsView()
    }
}
