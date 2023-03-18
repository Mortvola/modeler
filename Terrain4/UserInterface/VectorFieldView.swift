//
//  VectorFieldView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/11/23.
//

import SwiftUI

struct VectorFieldView: View {
    @Binding var vector: Vec3
    var label: [String] = ["X:", "Y:", "Z:"]
    
    var body: some View {
        VStack {
            LabeledNumericField(label: label[0], value: $vector[0])
            LabeledNumericField(label: label[1], value: $vector[1])
            LabeledNumericField(label: label[2], value: $vector[2])
        }
    }
}

struct VectorFieldView_Previews: PreviewProvider {
    static var previews: some View {
        VectorFieldView(vector: .constant(Vec3()))
    }
}
