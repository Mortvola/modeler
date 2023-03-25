//
//  ViewControllerRepresentable.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import Foundation
import SwiftUI

struct RenderView: UIViewControllerRepresentable {
    var file: SceneDocument
    
    typealias UIViewControllerType = RenderViewController
    
    func makeUIViewController(context: Context) -> RenderViewController {
        let viewController = RenderViewController()
        
        viewController.file = self.file
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: RenderViewController, context: Context) {
    }
}
