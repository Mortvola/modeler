//
//  AnimatorsDetailView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct AnimatorDetailsView: View {
    @ObservedObject var animator: Animator
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        VStack {
            HStack {
                Text("Details")
                Spacer()
                EditButton()
            }
            HStack {
                Text("Name:")
                TextField("Name", text: $animator.name)
            }
            HStack {
                Text("X:")
                TextField("X", value: $animator.delta[0], formatter: formatter)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Y:")
                TextField("Y", value: $animator.delta[1], formatter: formatter)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Z:")
                TextField("Z", value: $animator.delta[2], formatter: formatter)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

struct AnimatorDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatorDetailsView(animator: Animator())
    }
}
