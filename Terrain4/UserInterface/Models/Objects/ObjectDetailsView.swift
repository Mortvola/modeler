//
//  ObjectDetailsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct ObjectDetailsView: View {
    enum Tab {
        case transformations
        case material
    }

    @ObservedObject var object: RenderObject
    @State var tabState = Tab.transformations

    var body: some View {
        VStack {
            Picker(selection: $tabState, label: Text("Type")) {
                Text("Transformations").tag(Tab.transformations)
                Text("Material").tag(Tab.material)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if tabState == .transformations {
                ScrollView {
                    VStack {
                        HStack {
                            Text("Translation")
                            Spacer()
                        }
                        VectorFieldView(vector: $object.translation)
                            .padding(.leading, 16)
                    }
                    VStack {
                        HStack {
                            Text("Rotation")
                            Spacer()
                        }
                        VectorFieldView(vector: $object.rotation)
                            .padding(.leading, 16)
                    }
                    VStack {
                        HStack {
                            Text("Scale")
                            Spacer()
                        }
                        VectorFieldView(vector: $object.scale)
                            .padding(.leading, 16)
                    }
                }
            } else {
                ScrollView {
                    ObjectMaterialView(object: object)
                    Spacer()
                }
            }
        }
    }
}

struct ObjectDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectDetailsView(object: RenderObject(model: Model()))
    }
}
