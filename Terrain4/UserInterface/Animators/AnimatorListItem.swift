//
//  AnimatorListItem.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct AnimatorListItem: View {
    @ObservedObject var animator: Animator
    @Binding var selectedItem: Animator?
    
    var body: some View {
        ListItem(item: animator, selectedItem: $selectedItem)
    }
}

struct AnimatorListItem_Previews: PreviewProvider {
    static var previews: some View {
        AnimatorListItem(animator: Animator(), selectedItem: .constant(nil))
    }
}
