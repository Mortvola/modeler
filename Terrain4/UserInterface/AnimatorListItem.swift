//
//  AnimatorListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct AnimatorListItem: View {
    @ObservedObject var animator: Animator
    @ObservedObject var animatorStore = AnimatorStore.shared

    var body: some View {
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
        .buttonStyle(.plain)
    }
}

struct AnimatorListItem_Previews: PreviewProvider {
    static var previews: some View {
        AnimatorListItem(animator: Animator())
    }
}