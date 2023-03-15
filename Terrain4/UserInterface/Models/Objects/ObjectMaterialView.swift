//
//  ObjectMaterialView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/15/23.
//

import SwiftUI

struct ObjectMaterialView: View {
    @ObservedObject var object: RenderObject
    
    var body: some View {
        HStack {
            Picker("Type", selection: $object.material) {
                Text("None").tag(nil as Material?)
                ForEach(MaterialStore.shared.materials) { material in
                    Text(material.name).tag(material as Material?)
                }
            }
            .labelsHidden()
            Spacer()
        }
    }
}

struct ObjectMaterialView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectMaterialView(object: RenderObject(model: Model()))
    }
}
