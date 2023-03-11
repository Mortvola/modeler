//
//  LightsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct LightDetailsView: View {
    @ObservedObject var light: Light
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

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
                    HStack {
                        Text("Red:")
                        TextField("Red", value: $light.intensity[0], formatter: formatter)
                    }
                    HStack {
                        Text("Green:")
                        TextField("Green", value: $light.intensity[1], formatter: formatter)
                        Spacer()
                    }
                    HStack {
                        Text("Blue:")
                        TextField("Blue", value: $light.intensity[2], formatter: formatter)
                        Spacer()
                    }
                }
                .padding(.leading, 4)
            }
            .padding(.top, 8)
            VStack(spacing: 4) {
                HStack {
                    Text("Position:")
                    Spacer();
                }
                VStack(spacing: 4) {
                    HStack {
                        Text("X:")
                        TextField("X", value: $light.position[0], formatter: formatter)
                    }
                    HStack {
                        Text("Y:")
                        TextField("Y", value: $light.position[1], formatter: formatter)
                        Spacer()
                    }
                    HStack {
                        Text("Z:")
                        TextField("Z", value: $light.position[2], formatter: formatter)
                        Spacer()
                    }
                }
                .padding(.leading, 4)
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
