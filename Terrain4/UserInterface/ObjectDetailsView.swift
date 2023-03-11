//
//  ObjectDetailsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct ObjectDetailsView: View {
    @ObservedObject var object: Object

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Translation")
                    Spacer()
                }
                VStack {
                    LabeledNumericField(label: "X:", value: $object.translation.x)
                    LabeledNumericField(label: "Y:", value: $object.translation.y)
                    LabeledNumericField(label: "Z:", value: $object.translation.z)
                }
                .padding(.leading, 16)
            }
            VStack {
                HStack {
                    Text("Rotation")
                    Spacer()
                }
                VStack {
                    LabeledNumericField(label: "X:", value: $object.rotation.x)
                    LabeledNumericField(label: "Y:", value: $object.rotation.y)
                    LabeledNumericField(label: "Z:", value: $object.rotation.z)
                }
                .padding(.leading, 16)
            }
        }
    }
}

struct ObjectDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectDetailsView(object: Object(model: Model()))
    }
}
