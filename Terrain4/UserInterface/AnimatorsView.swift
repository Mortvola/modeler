//
//  AnimatorsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import SwiftUI

struct AnimatorsView: View {
    @ObservedObject var animatorStore = AnimatorStore.shared
    
    var body: some View {
        VStack {
            Button {
                animatorStore.addAnimator()
            } label: {
                Text("Add Animator")
            }
            .buttonStyle(.bordered)
            List {
                ForEach(animatorStore.animators) { animator in
                    AnimatorListItem(animator: animator)
                }
            }
            if let animator = animatorStore.selectedAnimator {
                AnimatorDetailsView(animator: animator)
            }
            Spacer()
        }
    }
}

struct AnimatorsView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatorsView()
    }
}
