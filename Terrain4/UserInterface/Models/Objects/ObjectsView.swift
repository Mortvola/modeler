//
//  ObjectsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct ObjectsView: View {
    @ObservedObject var objectStore = ObjectStore.shared
    @ObservedObject var model: Model
    
    var body: some View {
        ForEach($model.objects, id: \.id) { $object in
            ListItem(text: $object.name) {
                objectStore.selectObject(object);
            }
            .selected(selected: object == objectStore.selectedObject)
        }

        ForEach($model.lights, id: \.id) { $light in
            ListItem(text: $light.name) {
                objectStore.selectLight(light);
            }
            .selected(selected: light == objectStore.selectedLight)
        }
    }
}

struct ObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsView(model: Model())
    }
}
