//
//  TextureList.swift
//  Terrain4
//
//  Created by Richard Shields on 3/25/23.
//

import SwiftUI

struct TextureList: View {
    @Binding var selection: URL?
    @State private var isOpen = false
    
    var body: some View {
        Button {
            isOpen = true
        } label: {
            Image(systemName: "photo")
        }
        .sheet(isPresented: $isOpen) {
            List {
                ForEach(getTextures(), id: \.absoluteString) { url in
                    Button {
                        selection = url
                        isOpen  = false
                    } label: {
                        Text("\(url.lastPathComponent)")
                        
                    }
                        .buttonStyle(.plain)
                }
            }
        }
    }
    
    func getTextures() -> [URL] {
        let dir = getDocumentsDirectory().appending(path: "/textures")
        let urls = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [])
        
        return urls?.sorted { a, b in
            a.lastPathComponent < b.lastPathComponent
        } ?? []
    }
}

//struct TextureList_Previews: PreviewProvider {
//    static var previews: some View {
//        TextureList()
//    }
//}
