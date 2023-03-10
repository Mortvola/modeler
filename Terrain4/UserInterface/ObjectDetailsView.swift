//
//  ObjectDetailsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct ObjectDetailsView: View {
    @ObservedObject var object: Object
    let maxEditWidth: CGFloat = 100
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Translation")
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("X:")
                        TextField("X", value: $object.translation.x, formatter: formatter)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: maxEditWidth)
                        Spacer()
                    }
                    HStack {
                        Text("Y:")
                        TextField("Y", value: $object.translation.y, formatter: formatter)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: maxEditWidth)
                        Spacer()
                    }
                    HStack {
                        Text("Z:")
                        TextField("Z", value: $object.translation.z, formatter: formatter)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: maxEditWidth)
                        Spacer()
                    }
                }
                .padding(.leading, 16)
            }
            VStack {
                HStack {
                    Text("Rotation")
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("X:")
                        TextField("X", value: $object.rotation.x, formatter: formatter)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: maxEditWidth)
                        Spacer()
                    }
                    HStack {
                        Text("Y:")
                        TextField("Y", value: $object.rotation.y, formatter: formatter)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: maxEditWidth)
                        Spacer()
                    }
                    HStack {
                        Text("Z:")
                        TextField("Z", value: $object.rotation.z, formatter: formatter)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: maxEditWidth)
                        Spacer()
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
}

struct ObjectDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectDetailsView(object: Object(model: Model()))
    }
}
