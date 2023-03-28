//
//  AnimationView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/27/23.
//

import SwiftUI

struct AnimatorView: View {
    @Binding var animator: Animator
    
    var body: some View {
        HStack {
            Text(animator.name)
            UndoProvider($animator.value) { $value in
                NumericField(value: $value)
            }
        }
    }
}

//struct AnimatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimatorView()
//    }
//}
