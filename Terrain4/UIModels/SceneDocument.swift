//
//  Document.swift
//  Terrain4
//
//  Created by Richard Shields on 3/17/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static let sceneDocument = UTType(exportedAs: "app.richardshields.terrain4.scene")
}

class SceneDocument: ReferenceFileDocument {
    static let shared = SceneDocument()
    
    func snapshot(contentType: UTType) throws -> Data {
        return try encodeData()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = FileWrapper(regularFileWithContents: snapshot)
        
        return wrapper
    }
    
    typealias Snapshot = Data
    
    static var readableContentTypes: [UTType] { [UTType.sceneDocument] }
    static var writableContenttypes: [UTType] { [UTType.sceneDocument] }
    
    var data: Data?
    
    @Published var objectStore = ObjectStore()
    
    init() {
        
    }
    
    required init(configuration: ReadConfiguration) throws {
        // Do not open the file here. Need to have the metal view/device instantiated first
        self.data = configuration.file.regularFileContents
    }
    
    func encodeData() throws -> Data {
        let file = File(file: self)
        
        return try JSONEncoder().encode(file)
    }

//    func getURLFromBookmark(bookmark: Data) -> URL? {
//        var bookmarkIsStale = false
//        let url = try? URL(resolvingBookmarkData: bookmark, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &bookmarkIsStale)
//
//        if let url = url, bookmarkIsStale {
//            let bookmark = try? url.bookmarkData(options: .withSecurityScope)
//
//            self.bookmark = bookmark
//        }
//
//        return url
//    }
    
    @MainActor
    func parse(data: Data) async {
        do {
            let file = try JSONDecoder().decode(File.self, from: data)
            
            for materialDescriptor in file.materials {
                _ = try await MaterialManager.shared.addMaterial(device: Renderer.shared.device!, view: Renderer.shared.view!, descriptor: materialDescriptor)
            }

            var newLights: [Light] = []
            
            for model in file.models {
                for object in model.objects {
                    object.model = model

                    object.setMaterial(materialId: object.materialId)
                }
                
                model.lights.forEach { light in
                    light.model = model
                    newLights.append(light)
                }
            }
            
            objectStore.models = file.models
            objectStore.lights = newLights
            
            file.directionalLight.createShadowTexture(device: Renderer.shared.device!)
            
            objectStore.directionalLight = file.directionalLight

        } catch {
            print("Error: Can't decode contents \(error)")
        }
    }
    
//    @MainActor
//    func open(url: URL) async throws {
//        self.bookmark = try? url.bookmarkData(options: .withSecurityScope)
//
//        if let bookmark = self.bookmark, let url = getURLFromBookmark(bookmark: bookmark) {
//            if let data = try? Data(contentsOf: url) {
//                await parse(data: data)
//            }
//        }
//    }
}
