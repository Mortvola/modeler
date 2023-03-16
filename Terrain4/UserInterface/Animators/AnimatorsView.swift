//
//  AnimatorsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import SwiftUI

struct AnimatorsView: View {
    @ObservedObject var animatorStore = AnimatorStore.shared
    @State var hidden = false
    
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
                        .selected(selected: animator == animatorStore.selectedAnimator)
                }
            }
            if let animator = animatorStore.selectedAnimator, !hidden {
                AnimatorDetailsView(animator: animator)
                    .onChange(of: animatorStore.selectedAnimator) { _ in
                        hidden = true
                        Task {
                            hidden = false
                        }
                    }
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
