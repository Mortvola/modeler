//
//  ModelAnimationView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/27/23.
//

import SwiftUI

struct ModelAnimationView: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var file: SceneDocument
    @ObservedObject var model: SceneModel

    var body: some View {
        List {
            ForEach($model.animations, id: \.id) { $animation in
                AnimationView(animation: $animation)
            }
            .onMove { indexSet, destination in
                model.animations.move(fromOffsets: indexSet, toOffset: destination)
            }
            .onDelete { indexSet in
                model.animations.remove(atOffsets: indexSet)
            }
            
            Menu("Add Animation") {
                Button {
                    let animation = Animation(type: .rotateX)
                    animation.value = 20
                    model.addAnimation(animation: animation)
                    undoManager?.registerUndo(withTarget: file) { _ in
                        print("undo")
                    }
                } label: {
                    Text("Rotate X")
                }
                
                Button {
                    let animation = Animation(type: .rotateY)
                    animation.value = 20
                    model.addAnimation(animation: animation)
                    undoManager?.registerUndo(withTarget: file) { _ in
                        print("undo")
                    }
                } label: {
                    Text("Rotate Y")
                }
                
                Button {
                    let animation = Animation(type: .rotateZ)
                    animation.value = 20
                    model.addAnimation(animation: animation)
                    undoManager?.registerUndo(withTarget: file) { _ in
                        print("undo")
                    }
                } label: {
                    Text("Rotate Z")
                }
            }
            .buttonStyle(.borderless)
        }
    }
}

//struct ModelAnimationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelAnimationView()
//    }
//}
