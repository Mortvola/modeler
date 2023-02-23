//
//  GameViewController.swift
//  Terrain
//
//  Created by Richard Shields on 2/23/23.
//

import UIKit
import MetalKit
import Http

// Our iOS specific view controller
class GameViewController: UIViewController {

    var renderer: Renderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = view as? MTKView else {
            print("View of Gameview controller is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported")
            return
        }
        
        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.black

        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
        
        Task {
            let tileDimension = 128
            let latLng = LatLng(46.514279, -121.456191)
            let (x, y) = latLngToTerrainTile(latLng.lat, latLng.lng, tileDimension);

            if let response: Http.Response<TerrainTileProps> = try? await Http.get(path: "/tile/terrain3d/\(tileDimension)/\(x)/\(y)") {
                if let data = response.data {
                    let object = data.objects[0]
                    renderer.tile = TriangleMesh(device: renderer.device, points: object.points, normals: object.normals, indices: object.indices)
                }
            }
        }
    }
}
