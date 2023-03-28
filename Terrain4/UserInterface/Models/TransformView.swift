//
//  TransformView.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct TransformView: View {
    @ObservedObject var transform: Transform
    
    var body: some View {
        VStack {
            HStack {
                Picker("Type", selection: $transform.transform) {
                    ForEach(Transform.TransformType.allCases, id: \.rawValue) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                .labelsHidden()
                Spacer()
            }
            VectorFieldView(vector: $transform.values)
        }
    }
}

struct TransformView_Previews: PreviewProvider {
    static var previews: some View {
        TransformView(transform: Transform())
    }
}
