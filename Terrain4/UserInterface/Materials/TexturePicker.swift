//
//  TexturePicker.swift
//  Terrain4
//
//  Created by Richard Shields on 3/26/23.
//

import SwiftUI

struct TexturePicker: View {
    @Binding var map: String
    @State var url: URL? = nil
    
    var body: some View {
        HStack {
            Text("Map:")
            Text(map)
            Spacer()
            UndoProvider($url) { $url in
                TextureList(selection: $url)
                    .onChange(of: url) { newUrl in
                        map = newUrl?.lastPathComponent ?? ""
                    }
            }
        }
    }
}

//struct TexturePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        TexturePicker()
//    }
//}
