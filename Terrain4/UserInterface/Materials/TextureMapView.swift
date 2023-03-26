//
//  TextureMapView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/26/23.
//

import SwiftUI

struct TextureMapView: View {
    @ObservedObject var layer: MaterialLayer
    @State private var url: URL? = nil
    @State private var map: String = ""

    var body: some View {
        HStack {
            TexturePicker(map: $map)
                .onChange(of: map) { newMap in
                    Task {
                        await layer.setTexture(file: newMap)
                    }
                }
                .onAppear {
                    map = layer.map
                }
        }
    }
}

//struct TextureMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        TextureMapView()
//    }
//}
