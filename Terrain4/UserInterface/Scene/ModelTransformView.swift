//
//  ModelTransformView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/27/23.
//

import SwiftUI

struct ModelSceneDetails: View {
    enum Tab {
        case transformations
        case material
    }

    @ObservedObject var model: SceneModel
    @State var tabState = Tab.transformations

    var body: some View {
        VStack {
            Picker(selection: $tabState, label: Text("Type")) {
                Text("Transformations").tag(Tab.transformations)
                Text("Animations").tag(Tab.material)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if tabState == .transformations {
                VStack {
                    HStack {
                        Text("Translation")
                        Spacer()
                    }
                    VectorFieldView(vector: $model.translation)
                        .padding(.leading, 16)
                }
                VStack {
                    HStack {
                        Text("Rotation")
                        Spacer()
                    }
                    VectorFieldView(vector: $model.rotation)
                        .padding(.leading, 16)
                }
                VStack {
                    HStack {
                        Text("Scale")
                        Spacer()
                    }
                    VectorFieldView(vector: $model.scale)
                        .padding(.leading, 16)
                }
            }
            else {
                ModelAnimationView(model: model)
                Spacer()
            }
        }
    }
}

//struct ModelSceneDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelSceneDetails(object: RenderObject(model: Model()))
//    }
//}
