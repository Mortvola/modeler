//
//  ObjectsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct ObjectsView: View {
    @ObservedObject var model: Model
    
    var body: some View {
        ForEach(model.objects, id: \.id) { object in
            Text(object.name)
        }
    }
}

struct ObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsView(model: Model())
    }
}
