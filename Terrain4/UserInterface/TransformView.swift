//
//  TransformView.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct TransformView: View {
    @Binding var transform: Transform
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Picker("Type", selection: $transform.transform) {
                    ForEach(Transform.TransformType.allCases, id: \.rawValue) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                Spacer()
            }
            HStack {
                TextField("X", value: $transform.values.x, formatter: formatter)
                    .multilineTextAlignment(.trailing)
                TextField("Y", value: $transform.values.y, formatter: formatter)
                    .multilineTextAlignment(.trailing)
                TextField("Z", value: $transform.values.z, formatter: formatter)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                TextField("X", value: $transform.delta.x, formatter: formatter)
                    .multilineTextAlignment(.trailing)
                TextField("Y", value: $transform.delta.y, formatter: formatter)
                    .multilineTextAlignment(.trailing)
                TextField("Z", value: $transform.delta.z, formatter: formatter)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

struct TransformView_Previews: PreviewProvider {
    static var previews: some View {
        TransformView(transform: .constant(Transform()))
    }
}
