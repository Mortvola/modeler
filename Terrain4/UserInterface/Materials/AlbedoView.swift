//
//  AlbedoView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import SwiftUI

struct AlbedoView: View {
    @ObservedObject var material: PbrMaterial
    @State private var useSimple = true
    @State private var color = Color(.white)
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Albedo")
                Spacer()
            }
            VStack {
                HStack {
                    Text("Map:")
                    Text(material.albedo.map)
                    OpenFileButton(image: "photo") { url in
                        material.albedo.map = url
                    }
                }
                HStack {
                    CheckBox(checked: $useSimple, label: "Simple")
                    Spacer()
                }
                ColorPicker("", selection: $color)
            }
            .padding(.leading, 8)
        }
        .onChange(of: useSimple) { newUseSimple in
            material.albedo.useSimple = newUseSimple
        }
        .onAppear {
            useSimple = material.albedo.useSimple
        }
        .onChange(of: color) { newColor in
            material.setSimpleAlbedo(color.getColor())
        }
    }
}

//struct AlbedoView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbedoView(material: Material())
//    }
//}

extension Color {
    func getColor() -> Vec4 {
        let uiColor = UIColor(self)
        
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
        
//        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        if let c = uiColor.cgColor.components {
            return Vec4(Float(c[0]), Float(c[1]), Float(c[2]), Float(c[3]))
        }
        
        return  Vec4(0, 0, 0, 1)
    }
}
