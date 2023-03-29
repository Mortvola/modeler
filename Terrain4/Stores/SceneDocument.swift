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
    
    @Published var objectStore = ObjectStore()
    
    init() {
        
    }
    
    required init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents
        
        Task {
            if let data = data {
                await self.parse(data: data)
                objectStore.modelingScene.directionalLight = objectStore.directionalLight
                objectStore.loaded = true
            }
        }   
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
    
    @MainActor
    func parse(data: Data) async {
        do {
            let decoder = JSONDecoder()
            
            decoder.setContext(forKey: "Tasks", context: TaskHandler())
            decoder.setContext(forKey: "Store", context: objectStore)
            
            _ = try decoder.decode(File.self, from: data)
            
            // Wait for any tasks that were started during the JSON
            // decoding process.
            for task in decoder.getTasks().tasks {
                _ = await task.result
            }
        } catch {
            print("Error: Can't decode contents \(error)")
        }
    }
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
