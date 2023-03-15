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
                VectorFieldView(vector: $animator.delta)
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
