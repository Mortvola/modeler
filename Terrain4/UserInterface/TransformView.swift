//
//  TransformView.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct TransformView: View {
    @ObservedObject var transform: Transform
    @ObservedObject var animatorStore = AnimatorStore.shared
    
    var body: some View {
        VStack {
            HStack {
                Picker("Type", selection: $transform.transform) {
                    ForEach(Transform.TransformType.allCases, id: \.rawValue) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                .labelsHidden()
                Spacer()
            }
            VStack {
                LabeledNumericField(label: "X:", value: $transform.values.x)
                LabeledNumericField(label: "Y:", value: $transform.values.y)
                LabeledNumericField(label: "Z:", value: $transform.values.z)
            }
            HStack {
                Picker("Animator", selection: $transform.animator) {
                    Text("None").tag(nil as Animator?)
                    ForEach(animatorStore.animators, id: \.self) { animator in
                        AnimatorPickerItem(animator: animator)
                    }
                }
                .labelsHidden()
                Spacer()
            }
        }
    }
}

struct TransformView_Previews: PreviewProvider {
    static var previews: some View {
        TransformView(transform: Transform())
    }
}
