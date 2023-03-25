//
//  TexturesView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/18/23.
//

import SwiftUI
import MetalKit

struct TexturesView: View {
    @State private var openFile = false
    
    var body: some View {
        Button {
            openFile = true
        } label: {
            Image(systemName: "photo")
        }
        .fileImporter(isPresented: $openFile, allowedContentTypes: [.image]) { result in
            if let url = try? result.get() {
                try? importFile(srcUrl: url)
            }
        }
    }
    
    func importFile(srcUrl: URL) throws {
        let fileName = srcUrl.lastPathComponent
        
        let destUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("textures/\(fileName)")
        
        print(destUrl)
        
        try FileManager.default.copyItem(at: srcUrl, to: destUrl)
    }
    
    func convertSkyBox(url: URL) {
        if let d = try? Data(contentsOf: url), let i = UIImage(data: d), let cgImage = i.cgImage {
            let sideWidth = cgImage.width / 4
            if sideWidth == cgImage.height / 3 {
                let cropRects: [(CGRect, CGPoint)] = [
                    // X faces
                    (
                        CGRect(x: sideWidth * 2, y: sideWidth, width: sideWidth, height: sideWidth),
                        CGPoint(x: 0, y: sideWidth * 0)
                    ),
                    (
                        CGRect(x: 0, y: sideWidth, width: sideWidth, height: sideWidth),
                        CGPoint(x: 0, y: sideWidth * 1)
                    ),

                    // Y faces
                    (
                        CGRect(x: sideWidth, y: 0, width: sideWidth, height: sideWidth),
                        CGPoint(x: 0, y: sideWidth * 2)
                    ),
                    (
                        CGRect(x: sideWidth, y: sideWidth * 2, width: sideWidth, height: sideWidth),
                        CGPoint(x: 0, y: sideWidth * 3)
                    ),
                    
                    // Z Faces
                    (
                        CGRect(x: sideWidth, y: sideWidth, width: sideWidth, height: sideWidth),
                        CGPoint(x: 0, y: sideWidth * 4)
                    ),
                    (
                        CGRect(x: sideWidth * 3, y: sideWidth, width: sideWidth, height: sideWidth),
                        CGPoint(x: 0, y: sideWidth * 5)
                    )
                ]

                let size = CGSize(width: sideWidth, height: sideWidth * 6)
                UIGraphicsBeginImageContext(size)

                for (cropRect, point) in cropRects {
                    if let croppedImage = cgImage.cropping(to: cropRect) {
                        UIImage(cgImage: croppedImage).draw(at: point)
                    }
                }
                
                let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                if let pngData = newImage.pngData() {
                    let filename = url.lastPathComponent
                    let fileUrl = getDocumentsDirectory().appendingPathComponent(filename)
                    
                    try? pngData.write(to: fileUrl)
                }
            }
        }
    }
}

struct TexturesView_Previews: PreviewProvider {
    static var previews: some View {
        TexturesView()
    }
}
