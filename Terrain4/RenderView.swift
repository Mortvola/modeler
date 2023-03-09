//
//  ViewControllerRepresentable.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import Foundation
import SwiftUI

struct RenderView: UIViewControllerRepresentable {
    typealias UIViewControllerType = RenderViewController
    
    func makeUIViewController(context: Context) -> RenderViewController {
        return RenderViewController()
    }
    
    func updateUIViewController(_ uiViewController: RenderViewController, context: Context) {
    }
}
