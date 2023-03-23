//
//  SphereOptions.swift
//  Terrain4
//
//  Created by Richard Shields on 3/22/23.
//

import SwiftUI

struct SphereOptions {
    var diameter: Float = 5.0
    var radialSegments: Int = 32
    var verticalSegments: Int = 32
    var hemisphere = false
}

struct SphereOptionsView: View {
    @Binding var options: SphereOptions
    
    var body: some View {
        HStack {
            Text("Diameter:")
            NumericField(value: $options.diameter)
                .frame(width: 64)
            Spacer()
        }
        HStack {
            Text("Radial Segments:")
            TextField("", value: $options.radialSegments, formatter: NumberFormatter())
                .frame(width: 64)
                .multilineTextAlignment(.trailing)
            Spacer()
        }
        HStack {
            Text("Vertical Segments:")
            TextField("", value: $options.verticalSegments, formatter: NumberFormatter())
                .frame(width: 64)
                .multilineTextAlignment(.trailing)
            Spacer()
        }
        HStack {
            CheckBox(checked: $options.hemisphere, label: "Hemisphere")
            Spacer()
        }
    }
}

struct SphereOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SphereOptionsView(options: .constant(SphereOptions()))
    }
}
