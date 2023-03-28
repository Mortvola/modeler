//
//  ImportObj.swift
//  Terrain4
//
//  Created by Richard Shields on 3/28/23.
//

import SwiftUI

struct ImportObj: View {
    @State private var openFile = false
//    var image: String
    var action: (_ url: URL?) -> Void
    
    var body: some View {
        Button {
            openFile = true
        } label: {
            Image(systemName: "photo")
        }
        .fileImporter(isPresented: $openFile, allowedContentTypes: [.data]) { result in
            let srcUrl = try? result.get()
            action(srcUrl)
        }
    }
}

//struct ImportObj_Previews: PreviewProvider {
//    static var previews: some View {
//        ImportObj()
//    }
//}
