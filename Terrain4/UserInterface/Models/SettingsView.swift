//
//  SettingsView.swift
//  Terrain4
//
//  Created by Richard Shields on 4/4/23.
//

import SwiftUI

func numberFormatter() -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 1
    formatter.maximumFractionDigits = 5
    
    return formatter
}

struct SettingsView: View {
    @ObservedObject var objectStore: ObjectStore
    @State private var value1: Float = 0
    @State private var value2: Float = 0
    @State private var value3: Float = 0
    private let formatter = numberFormatter()
    @State private var bias: Float = 0
    @State private var slopeScale: Float = 0
    @State private var clamp: Float = 0

    var body: some View {
        VStack {
            HStack {
                Text("Frustum Splits (%):")
                Spacer()
            }
            HStack {
                VStack {
                    TextField("", value: $value1, formatter: numberFormatter())
                        .multilineTextAlignment(.trailing)
                        .onAppear {
                            value1 = Renderer.shared.frustumSegments[1]
                        }
                        .onChange(of: value1) { newValue in
                            Renderer.shared.frustumSegments[1] = newValue
                        }
                    TextField("", value: $value2, formatter: numberFormatter())
                        .multilineTextAlignment(.trailing)
                        .onAppear {
                            value2 = Renderer.shared.frustumSegments[2]
                        }
                        .onChange(of: value2) { newValue in
                            Renderer.shared.frustumSegments[2] = newValue
                        }
                    TextField("", value: $value3, formatter: numberFormatter())
                        .multilineTextAlignment(.trailing)
                        .onAppear {
                            value3 = Renderer.shared.frustumSegments[3]
                        }
                        .onChange(of: value3) { newValue in
                            Renderer.shared.frustumSegments[3] = newValue
                        }
                }
                .frame(maxWidth: 100)
                Spacer()
            }
            HStack {
                Text("Depth Bias:")
                Spacer()
            }
            HStack {
                VStack {
                    TextField("", value: $bias, formatter: numberFormatter())
                        .multilineTextAlignment(.trailing)
                        .onAppear {
                            bias = Renderer.shared.depthBias
                        }
                        .onChange(of: bias) { newValue in
                            Renderer.shared.depthBias = newValue
                        }
                    TextField("", value: $slopeScale, formatter: numberFormatter())
                        .multilineTextAlignment(.trailing)
                        .onAppear {
                            slopeScale = Renderer.shared.slopeScale
                        }
                        .onChange(of: slopeScale) { newValue in
                            Renderer.shared.slopeScale = newValue
                        }
                    TextField("", value: $clamp, formatter: numberFormatter())
                        .multilineTextAlignment(.trailing)
                        .onAppear {
                            clamp = Renderer.shared.biasClamp
                        }
                        .onChange(of: clamp) { newValue in
                            Renderer.shared.biasClamp = newValue
                        }
                }
                .frame(maxWidth: 100)
                Spacer()
            }
            Spacer()
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
