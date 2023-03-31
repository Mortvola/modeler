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
    @State var selectedItem: URL? = nil
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    openFile = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .fileImporter(isPresented: $openFile, allowedContentTypes: [.image]) { result in
                    if let url = try? result.get() {
                        try? importFile(srcUrl: url)
                    }
                }
                Button {
                    if let url = selectedItem {
                        try? flipTexutre(url: url)
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            List {
                ForEach(getTextures(), id: \.absoluteString) { url in
                    Button {
                        selectedItem = url
                    } label: {
                        HStack {
                            Text("\(url.lastPathComponent)")
                            Spacer()
                        }
                    }
                    .selected(selected: url == selectedItem)
                }
            }
            Spacer()
        }
    }
    
    func getTextures() -> [URL] {
        let dir = getDocumentsDirectory().appending(path: "/textures")
        let urls = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [])
        
        return urls?.sorted { a, b in
            a.lastPathComponent < b.lastPathComponent
        } ?? []
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
    
    func flipTexutre(url: URL) throws {
        do {
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data), let cgImage = image.cgImage {
                var ciImage = CIImage(cgImage: cgImage)
                    .transformed(by: CGAffineTransform(scaleX: 1.0, y: -1.0))
                let t2 = UIImage(ciImage: ciImage)
                    
                if let pngData = t2.pngData() {
                    try pngData.write(to: url)
                }
            }
        }
        catch {
            print(error)
        }
    }
}

struct TexturesView_Previews: PreviewProvider {
    static var previews: some View {
        TexturesView()
    }
}
