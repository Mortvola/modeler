//
//  ObjectsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct ObjectsView: View {
    @ObservedObject var objectStore: ObjectStore
    @ObservedObject var model: Model
    
    var body: some View {
        ForEach($model.objects, id: \.id) { $object in
            ListItem(node: object) {
                objectStore.selectObject(object);
            }
            .selected(selected: SelectedNode.object(object) == objectStore.selectedNode)
        }

        ForEach($model.lights, id: \.id) { $light in
            ListItem(node: light) {
                objectStore.selectLight(light);
            }
            .selected(selected: SelectedNode.light(light) == objectStore.selectedNode)
        }
    }
}

struct ObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsView(objectStore: ObjectStore(), model: Model())
    }
}
