//
//  BillboardOptionsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/23/23.
//

import SwiftUI

struct BillboardOptions {
    var dimensions: Vec2 = Vec2(1.0, 1.0)
}

struct BillboardOptionsView: View {
    @Binding var options: BillboardOptions
    
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
        }
    }
}

struct BillboardOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        BillboardOptionsView(options: .constant(BillboardOptions()))
    }
}
