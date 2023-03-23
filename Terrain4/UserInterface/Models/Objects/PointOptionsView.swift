//
//  PointOptionsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import SwiftUI

struct PointOptions {
    var size: Float = 5
}

struct PointOptionsView: View {
    @Binding var options: PointOptions
    
    var body: some View {
        HStack {
            Text("Size:")
            TextField("", value: $options.size, formatter: NumberFormatter())
                .frame(width: 64)
                .multilineTextAlignment(.trailing)
            Spacer()
        }
    }
}

struct PointOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        PointOptionsView(options: .constant(PointOptions()))
    }
}
