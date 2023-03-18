//
//  DirectionalLightView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/18/23.
//

import SwiftUI

struct DirectionalLightView: View {
    @ObservedObject var light: DirectionalLight
    
    var body: some View {
        VStack {
            HStack {
                CheckBox(checked: $light.enabled, label: "Enabled")
                Spacer()
            }
            VectorFieldView(vector: $light.direction)
            Spacer()
        }
    }
}

struct DirectionalLightView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionalLightView(light: DirectionalLight(name: "Directional Light"))
    }
}
