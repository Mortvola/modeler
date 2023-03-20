//
//  LabeledNumericField.swift
//  Terrain4
//
//  Created by Richard Shields on 3/11/23.
//

import SwiftUI

struct LabeledNumericField: View {
    var label: String
    @Binding var value: Float
    let maxEditWidth: CGFloat = 175

    var body: some View {
        HStack {
            HStack {
                Text(label)
                Spacer()
                UndoProvider($value) { $value in
                    NumericField(value: $value)
                }
            }
            .frame(maxWidth: maxEditWidth)
            Spacer()
        }
    }
}

struct LabeledNumericField_Previews: PreviewProvider {
    static var previews: some View {
        LabeledNumericField(label: "Test", value: .constant(100))
    }
}
