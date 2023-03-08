//
//  ObjectsView.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct ObjectsView: View {
    @ObservedObject var objectStore = ObjectStore.shared
    @State var editedObject: Model? = nil
    @State var selection: Model?
    
    var body: some View {
        VStack {
            List {
                ForEach(ObjectStore.shared.objects, id: \.id) { object in
                    Button {
                        if selection == object {
                            selection = nil
                        }
                        else {
                            selection = object
                        }
                    } label: {
                        HStack {
                            Text(object.name)
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .background(selection == object ? Color(.lightGray) : Color(.white))
                }
            }
            .padding()
            
            if let selection = selection {
                TransformsView(object: selection)
            }
        }
    }
}

struct ObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsView()
    }
}
