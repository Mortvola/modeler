//
//  AnimatorStore.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import Foundation

class AnimatorStore: ObservableObject {
    static let shared = AnimatorStore()
    
    @Published var animators: [Animator] = []
    @Published var selectedAnimator: Animator?
    
    private var animatorCounter = 0

    func addAnimator() {
        let animator = Animator()
        animator.name = "Animator_\(animatorCounter)"
        animatorCounter += 1
        
        self.animators.append(animator)
        self.selectedAnimator = animator
    }
}
