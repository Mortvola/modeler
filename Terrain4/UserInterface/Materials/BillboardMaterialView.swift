//
//  BillboardMaterialView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/29/23.
//

import SwiftUI

struct BillboardMaterialView: View {
    @ObservedObject var material: BillboardMaterial
    @State var map: String = ""
    @State private var color = Color(.white)

    var body: some View {
        VStack {
            TexturePicker(map: $map)
                .onChange(of: map) { newMap in
                    Task {
                        await material.setTexture(file: newMap)
                    }
                }
                .onAppear {
                    map = material.filename
                }
            UndoProvider($color) { $value in
                ColorPicker("", selection: $value)
            }
            .onChange(of: color) { newColor in
                material.color = color.getColor()
            }
            .onAppear {
                color = Color(red: Double(material.color[0]), green: Double(material.color[1]), blue: Double(material.color[2]))
            }
        }
    }
}

//struct BillboardMaterialView_Previews: PreviewProvider {
//    static var previews: some View {
//        BillboardMaterialView()
//    }
//}
