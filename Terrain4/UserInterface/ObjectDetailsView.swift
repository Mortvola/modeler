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
    }
}

struct ObjectDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectDetailsView(object: Object(model: Model()))
    }
}
