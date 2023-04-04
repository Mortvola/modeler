//
//  App.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import SwiftUI

@main
struct TestApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        DocumentGroup(newDocument: { SceneDocument() }) { file in
            ContentView(file: file.document)
        }
        .commands {
            CommandMenu("Video") {
                Button {
                    Renderer.shared.startVideoCapture()
                } label: {
                    Text("Record")
                }
            }
            CommandGroup(after: .newItem) {
                Button {
                    Renderer.shared.showFrustum()
                } label: {
                    Text("Freeze Frustum")
                }
            }
        }
    }
}
