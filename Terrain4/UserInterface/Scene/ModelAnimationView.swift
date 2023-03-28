//
//  ModelAnimatorView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/27/23.
//

import SwiftUI

struct ModelAnimatorView: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var file: SceneDocument
    @ObservedObject var model: SceneModel

    var body: some View {
        List {
            ForEach($model.animators, id: \.id) { $animator in
                AnimatorView(animator: $animator)
            }
            .onMove { indexSet, destination in
                model.animators.move(fromOffsets: indexSet, toOffset: destination)
            }
            .onDelete { indexSet in
                model.animators.remove(atOffsets: indexSet)
            }
            
            Menu("Add Animator") {
                Button {
                    let animator = Animator(type: .rotateX)
                    animator.value = 20
                    model.addAnimator(animator: animator)
                    undoManager?.registerUndo(withTarget: file) { _ in
                        print("undo")
                    }
                } label: {
                    Text("Rotate X")
                }
                
                Button {
                    let animator = Animator(type: .rotateY)
                    animator.value = 20
                    model.addAnimator(animator: animator)
                    undoManager?.registerUndo(withTarget: file) { _ in
                        print("undo")
                    }
                } label: {
                    Text("Rotate Y")
                }
                
                Button {
                    let animator = Animator(type: .rotateZ)
                    animator.value = 20
                    model.addAnimator(animator: animator)
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

//struct ModelAnimatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelAnimatorView()
//    }
//}
