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
                    Button {
                        if animatorStore.selectedAnimator == animator {
                            animatorStore.selectedAnimator = nil
                        }
                        else {
                            animatorStore.selectedAnimator = animator
                        }
                    } label: {
                        Text(animator.name)
                    }
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
