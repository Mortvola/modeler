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
        ForEach(model.objects, id: \.id) { object in
            Button {
                if objectStore.selectedObject == object {
                    objectStore.selectObject(nil);
                }
                else {
                    objectStore.selectObject(object);
                }
            } label: {
                HStack {
                    Text(object.name)
                        .foregroundColor(.black)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .background(objectStore.selectedObject == object ? Color(.lightGray) : Color(.white))
        }
    }
}

struct ObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsView(model: Model())
    }
}
