//
//  TextureLayerView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/26/23.
//

import SwiftUI

struct TextureLayerView: View {
    @ObservedObject var layer: Texture
    @State var texture: String = ""
    
    var body: some View {
        TexturePicker(map: $texture)
            .onAppear {
                texture = layer.filename
            }
            .onChange(of: texture) { newTexture in
                Task {
                    await layer.setTexture(file: newTexture)
                }
            }
    }
}

//struct TextureLayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        TextureLayerView()
//    }
//}
