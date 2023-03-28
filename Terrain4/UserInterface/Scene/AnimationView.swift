//
//  AnimationView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/27/23.
//

import SwiftUI

struct AnimationView: View {
    @Binding var animation: Animation
    
    var body: some View {
        HStack {
            Text(animation.name)
            UndoProvider($animation.value) { $value in
                NumericField(value: $value)
            }
        }
    }
}

//struct AnimationView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimationView()
//    }
//}
