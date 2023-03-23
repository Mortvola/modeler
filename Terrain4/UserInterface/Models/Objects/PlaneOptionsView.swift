//
//  PlaneOptionsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/22/23.
//

import SwiftUI

struct PlaneOptions {
    var dimensions: Vec2 = Vec2(5.0, 5.0)
    var segments: VecUInt2 = VecUInt2(5, 5)
}

struct PlaneOptionsView: View {
    @Binding var options: PlaneOptions
    
    var body: some View {
        VStack {
            HStack {
                Text("Dimensions:")
                Spacer()
            }
            VStack {
                HStack {
                    Text("X:")
                    TextField("", value: $options.dimensions.x, formatter: NumberFormatter())
                        .frame(width: 64)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
                HStack {
                    Text("Y:")
                    TextField("", value: $options.dimensions.y, formatter: NumberFormatter())
                        .frame(width: 64)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
            }
            .padding(.leading, 16)
            HStack {
                Text("Number of Segments:")
                Spacer()
            }
            VStack {
                HStack {
                    Text("X:")
                    TextField("", value: $options.segments.x, formatter: NumberFormatter())
                        .frame(width: 64)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
                HStack {
                    Text("Y:")
                    TextField("", value: $options.segments.y, formatter: NumberFormatter())
                        .frame(width: 64)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
            }
            .padding(.leading, 16)
        }
    }
}

struct PlaneOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        PlaneOptionsView(options: .constant(PlaneOptions()))
    }
}
