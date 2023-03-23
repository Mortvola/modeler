//
//  CylinderOptionsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/22/23.
//

import SwiftUI

struct CylinderOptions {
    var height: Float = 5.0
    var radii: Vec2 = Vec2(5.0, 5.0)
    var radialSegments: Int = 32
    var verticalSegments: Int = 5
}

struct CylinderOptionsView: View {
    @Binding var options: CylinderOptions
    
    var body: some View {
        VStack {
            HStack {
                Text("Dimensions:")
                Spacer()
            }
            VStack {
                HStack {
                    Text("Height:")
                    TextField("", value: $options.height, formatter: NumberFormatter())
                        .frame(width: 64)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
                HStack {
                    Text("Radius X:")
                    TextField("", value: $options.radii.x, formatter: NumberFormatter())
                        .frame(width: 64)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
                HStack {
                    Text("Radius Z:")
                    TextField("", value: $options.radii.y, formatter: NumberFormatter())
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
                    Text("Radial:")
                    TextField("", value: $options.radialSegments, formatter: NumberFormatter())
                        .frame(width: 64)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
                HStack {
                    Text("Vertical:")
                    TextField("", value: $options.verticalSegments, formatter: NumberFormatter())
                        .frame(width: 64)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
            }
            .padding(.leading, 16)
        }
    }
}

struct CylinderOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        CylinderOptionsView(options: .constant(CylinderOptions()))
    }
}
