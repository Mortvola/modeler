//
//  EditObject.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct EditObject: View {
    @State var object: Model

    var body: some View {
        Text("Transforms:")
        Button {
            
        } label: {
            Text("Add Transformation")
        }
    }
}

struct EditObject_Previews: PreviewProvider {
    static var previews: some View {
        EditObject(object: Model())
    }
}
