//
//  AnimatorsDetailView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct AnimatorDetailsView: View {
    @ObservedObject var animator: Animator
    
    var body: some View {
        VStack {
            HStack {
                Text("Details")
                Spacer()
            }
            VStack {
                HStack {
                    Text("Name:")
                    TextField("Name", text: $animator.name)
                }
                LabeledNumericField(label: "X:", value: $animator.delta[0])
                LabeledNumericField(label: "Y:", value: $animator.delta[1])
                LabeledNumericField(label: "Z:", value: $animator.delta[2])
            }
            .padding(.leading, 16)
        }
    }
}

struct AnimatorDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatorDetailsView(animator: Animator())
    }
}
