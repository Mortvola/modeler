//
//  OpenFileButton.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct OpenFileButton: View {
    @State private var openFile = false
    var image: String
    var action: (_ url: String) -> Void
    
    var body: some View {
        Button {
            openFile = true
        } label: {
            Image(systemName: "photo")
        }
        .fileImporter(isPresented: $openFile, allowedContentTypes: [.image]) { result in
            var destUrl: URL? = nil
            do {
                let srcUrl = try result.get()
                
                let fileName = srcUrl.lastPathComponent
                
                destUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
                
                if let destUrl = destUrl {
                    try FileManager.default.copyItem(at: result.get(), to: destUrl)
                }
            }
            catch {
                print(error)
            }
            action(destUrl?.lastPathComponent ?? "")
        }
    }
}

struct OpenFileButton_Previews: PreviewProvider {
    static var previews: some View {
        OpenFileButton(image: "Photo") { url in
            print(url)
        }
    }
}
