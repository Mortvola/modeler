//
//  BoxOptionsView.swift
//  Http
//
//  Created by Richard Shields on 3/22/23.
//

import SwiftUI

struct BoxOptions {
    var dimensions: Vec3 = Vec3(1.0, 1.0, 1.0)
    var segments: VecUInt3 = VecUInt3(1, 1, 1)
}

struct BoxOptionsView: View {
    @Binding var options: BoxOptions
    
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
                HStack {
                    Text("Z:")
                    TextField("", value: $options.dimensions.z, formatter: NumberFormatter())
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
                HStack {
                    Text("Z:")
                    TextField("", value: $options.segments.z, formatter: NumberFormatter())
                        .frame(width: 64)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
            }
            .padding(.leading, 16)
        }
    }
}

struct BoxOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        BoxOptionsView(options: .constant(BoxOptions()))
    }
}
