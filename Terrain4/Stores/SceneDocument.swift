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
        do {
            let file = File(file: self)
            
            return try JSONEncoder().encode(file)
        }
        catch {
            print(error)
            throw error
        }
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
            let decoder = JSONDecoder()
            
            decoder.setContext(forKey: "Tasks", context: TaskHandler())
            decoder.setContext(forKey: "Store", context: objectStore)
            
            let file = try decoder.decode(File.self, from: data)
            
            for task in decoder.getTasks().tasks {
                _ = await task.result
            }
            
//            for material in file.materials {
//                Renderer.shared.materialManager!.materials[material.material.id] = material
//            }
            
            var newLights: [Light] = []
            
            for node in file.models {
                switch node.content {
                case .model(let model):
                    for object in model.objects {
                        switch object.content {
                        case .mesh(let o):
                            o.model = model
//                            o.setMaterial(materialId: o.materialId)
                        case .point(let p):
                            p.model = model
//                            p.setMaterial(materialId: p.materialId)
                        default:
                            break;
                        }
                    }

                    model.lights.forEach { light in
                        light.model = model
                        newLights.append(light)
                    }

                case .mesh:
                    break
                case .point:
                    break
                case .light:
                    break
                case .directionalLight:
                    break
                }
            }
            
            objectStore.models = file.models
            objectStore.lights = newLights
            objectStore.scene.models = file.scene
            
            for sceneModel in objectStore.scene.models {
                for node in objectStore.models {
                    switch node.content {
                    case .model(let m):
                        if m.id == sceneModel.modelId {
                            sceneModel.model = m
                        }
                    default:
                        break
                    }
                }
                
                for node in sceneModel.model!.objects {
                    switch node.content {
                    case .light(let l):
                        objectStore.scene.lights.append(l)
                    default:
                        break
                    }
                }
            }
            
            file.directionalLight.createShadowTexture()
            
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

class TaskHandler {
    var tasks: [Task<Void, Never>] = []
}

extension Decoder {
    func getContext(forKey key: String) -> Any? {
        let key = CodingUserInfoKey(rawValue: key)!
        return userInfo[key]
    }
    
    func getTasks() -> TaskHandler {
        getContext(forKey: "Tasks") as! TaskHandler
    }
    
    func getObjectStore() -> ObjectStore {
        getContext(forKey: "Store") as! ObjectStore
    }
    
    func addTask(_ task: Task<Void, Never>) {
        let context = getContext(forKey: "Tasks") as! TaskHandler
        context.tasks.append(task)
    }
}

extension JSONDecoder {
    func setContext(forKey key: String, context: Any?) {
        let key = CodingUserInfoKey(rawValue: key)!
        userInfo[key] = context
    }
    
    func getContext(forKey key: String) -> Any? {
        let key = CodingUserInfoKey(rawValue: key)!
        return userInfo[key]
    }

    func getTasks() -> TaskHandler {
        getContext(forKey: "Tasks") as! TaskHandler
    }
}
