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
    
    var body: some View {
        TexturePicker(map: $map)
            .onChange(of: map) { newMap in
                Task {
                    await material.setTexture(file: newMap)
                }
            }
    }
}

//struct BillboardMaterialView_Previews: PreviewProvider {
//    static var previews: some View {
//        BillboardMaterialView()
//    }
//}
