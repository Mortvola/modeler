//
//  ObjectsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct ObjectsView: View {
    @EnvironmentObject private var file: SceneDocument
    @ObservedObject var model: Model
    
    var body: some View {
        ForEach($model.objects, id: \.id) { $object in
            ListItem(node: object) {
                file.objectStore.selectObject(object);
            }
            .selected(selected: SelectedNode.object(object) == file.objectStore.selectedNode)
        }

        ForEach($model.lights, id: \.id) { $light in
            ListItem(node: light) {
                file.objectStore.selectLight(light);
            }
            .selected(selected: SelectedNode.light(light) == file.objectStore.selectedNode)
        }
    }
}

struct ObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsView(model: Model())
    }
}
