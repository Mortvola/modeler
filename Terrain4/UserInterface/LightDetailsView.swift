//
//  LightsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct LightDetailsView: View {
    @ObservedObject var light: Light
    
    var body: some View {
        VStack {
            HStack {
                CheckBox(checked: $light.pointLight, label: "Point Light")
                Spacer()
            }
            VStack(spacing: 4) {
                HStack {
                    Text("Light Intensity:")
                    Spacer();
                }
                VStack(spacing: 4) {
                    LabeledNumericField(label: "Red:", value: $light.intensity[0])
                    LabeledNumericField(label: "Green:", value: $light.intensity[1])
                    LabeledNumericField(label: "Blue:", value: $light.intensity[2])
                }
                .padding(.leading, 16)
            }
            .padding(.top, 8)
            VStack(spacing: 4) {
                HStack {
                    Text("Position:")
                    Spacer();
                }
                VectorFieldView(vector: $light.position)
                    .padding(.leading, 16)
            }
            .padding(.top, 8)
        }
    }
}

struct LightDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        LightDetailsView(light: Light(model: Model()))
    }
}
