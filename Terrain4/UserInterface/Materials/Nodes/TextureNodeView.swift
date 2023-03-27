//
//  TextureLayerView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/26/23.
//

import SwiftUI

struct TextureNodeView: View {
    @ObservedObject var node: GraphNodeTexture
    @State var texture: String = ""
    
    var body: some View {
        TexturePicker(map: $texture)
            .onAppear {
                texture =  node.filename
            }
            .onChange(of: texture) { newTexture in
                Task {
                    await  node.setTexture(file: newTexture)
                }
            }
    }
}

//struct TextureLayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        TextureLayerView()
//    }
//}
