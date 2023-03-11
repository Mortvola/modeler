//
//  VectorFieldView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/11/23.
//

import SwiftUI

struct VectorFieldView: View {
    @Binding var vector: Vec3
    
    var body: some View {
        VStack {
            LabeledNumericField(label: "X:", value: $vector[0])
            LabeledNumericField(label: "Y:", value: $vector[1])
            LabeledNumericField(label: "Z:", value: $vector[2])
        }
    }
}

struct VectorFieldView_Previews: PreviewProvider {
    static var previews: some View {
        VectorFieldView(vector: .constant(Vec3()))
    }
}
