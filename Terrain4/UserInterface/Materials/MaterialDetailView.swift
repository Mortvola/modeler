//
//  MaterialDetailView.swift
//  Terrain4
//
//  Created by Richard Shields on 3/14/23.
//

import SwiftUI

struct MaterialDetailView: View {
    @ObservedObject var material: Material
    
    var body: some View {
        HStack {
            Text("Albedo")
            TextField("", text: $material.albedo)
            OpenFileButton(image: "photo") { url in
                material.albedo = url
            }
        }
        
        HStack {
            Text("Normals")
            TextField("", text: $material.normals)
            OpenFileButton(image: "photo") { url in
                material.normals = url
            }
        }

        HStack {
            Text("Metalness")
            TextField("", text: $material.metalness)
            OpenFileButton(image: "photo") { url in
                material.metalness = url
            }
        }
        
        HStack {
            Text("Rougness")
            TextField("", text: $material.roughness)
            OpenFileButton(image: "photo") { url in
                material.roughness = url
            }
        }
    }
}

struct MaterialDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialDetailView(material: Material())
    }
}
