//
//  ModelDetailsView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/10/23.
//

import SwiftUI

struct ModelDetailsView: View {
    @ObservedObject var model: Model
    
    var body: some View {
        TransformsView(model: model)
    }
}

struct ModelDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ModelDetailsView(model: Model())
    }
}
