//
//  AlbedoView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import SwiftUI

struct AlbedoView: View {
    @ObservedObject var albedo: AlbedoLayer
    @State private var useSimple = true
    @State private var color = Color(.white)
    @State private var url: URL? = nil
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Albedo")
                Spacer()
            }
            VStack {
                TextureMapView(layer: albedo)
                HStack {
                    UndoProvider($useSimple) { $value in
                        CheckBox(checked: $value, label: "Simple")
                    }
                    Spacer()
                }
                UndoProvider($color) { $value in
                    ColorPicker("", selection: $value)
                }
            }
            .padding(.leading, 8)
        }
        .onChange(of: useSimple) { newUseSimple in
            albedo.useSimple = newUseSimple
        }
        .onAppear {
            useSimple = albedo.useSimple
        }
        .onChange(of: color) { newColor in
            albedo.color = color.getColor()
        }
        .onAppear {
            color = Color(red: Double(albedo.color[0]), green: Double(albedo.color[1]), blue: Double(albedo.color[2]))
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
        if let c = uiColor.cgColor.components {
            return Vec4(Float(c[0]), Float(c[1]), Float(c[2]), Float(c[3]))
        }
        
        return  Vec4(0, 0, 0, 1)
    }
//    func setColor(color: Vec4) {
//        let uiColor = UIColor(self)
//        uiColor.cgColor.components.
//    }
}
