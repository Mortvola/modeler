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

    var body: some View {
        HStack {
            Text("Map:")
            Text(layer.map)
            Spacer()
            UndoProvider($url) { $url in
                TextureList(selection: $url)
                    .onChange(of: url) { newUrl in
                        Task {
                            await layer.setTexture(file: newUrl?.lastPathComponent ?? "")
                        }
                    }
            }
        }
    }
}

//struct TextureMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        TextureMapView()
//    }
//}
