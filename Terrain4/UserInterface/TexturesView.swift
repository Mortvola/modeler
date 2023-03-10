//
//  TexturesView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/9/23.
//

import SwiftUI

struct TexturesView: View {
    @State var openFile = false

    var body: some View {
        VStack {
            Button {
                openFile = true
            } label: {
                Text("Import Texture")
            }
            .buttonStyle(.bordered)
        }
        .fileImporter(isPresented: $openFile, allowedContentTypes: [.image]) { result in
            try? TextureStore.shared.addTexture(url: result.get())
        }
    }
}

struct TexturesView_Previews: PreviewProvider {
    static var previews: some View {
        TexturesView()
    }
}
