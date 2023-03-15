//
//  AnimatorPickerItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct AnimatorPickerItem: View {
    @ObservedObject var animator: Animator
    
    var body: some View {
        Text(animator.name).tag(animator as Animator?)
    }
}

struct AnimatorPickerItem_Previews: PreviewProvider {
    static var previews: some View {
        AnimatorPickerItem(animator: Animator())
    }
}
