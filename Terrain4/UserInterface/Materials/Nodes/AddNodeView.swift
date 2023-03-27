//
//  AddNodeView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/26/23.
//

import SwiftUI

struct AddNodeView: View {
    @ObservedObject var node: GraphNodeAdd
    @State private var value: Float = 0.0

    var body: some View {
        HStack {
            Text("Add:")
            NumericField(value: $value)
                .frame(maxWidth: 128)
                .onChange(of: value) { newValue in
                    node.value = newValue
                }
                .onAppear {
                    value = node.value
                }
            Spacer()
        }
    }
}

//struct AddNodeView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddNodeView()
//    }
//}
