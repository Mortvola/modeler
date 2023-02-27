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
    
    var forward = 0
    var backward = 0
    var left = 0
    var right = 0
    var up = 0
    var down = 0
    
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
        
        Task {
            await renderer.load(lat: 46.514279, lng: -121.456191, dimension: 128)
        }

        renderer = newRenderer
        
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        
        mtkView.delegate = renderer        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touches began")
//    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            let point = touch.preciseLocation(in: view)
            let prevPoint = touch.precisePreviousLocation(in: view)

            let xDelta = -Float(point.x - prevPoint.x);
            let yDelta = Float(point.y - prevPoint.y);
            let sensitivity: Float = 0.1;

            renderer.camera.updateLookAt(yawChange: xDelta * sensitivity, pitchChange: yDelta * sensitivity);
        }
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touches ended")
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touches cancelled")
//    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var keyPressed = false;
        
        presses.forEach{ press in
            if let key = press.key?.charactersIgnoringModifiers {
              switch (key) {
                case "e":
                  self.forward = 1
                  keyPressed = true
                  break;

                case "d":
                  self.backward = 1
                  keyPressed = true
                  break;

                case "s":
                  self.left = 1
                  keyPressed = true
                  break;

                case "f":
                  self.right = 1
                  keyPressed = true
                  break;

                case "t":
                  self.up = 1
                  keyPressed = true
                  break;

                case "g":
                  self.down = 1
                  keyPressed = true
                  break;

                default:
                  break;
              }
            }
        }

        if keyPressed {
            renderer.camera.setVelocity(
                x: Float(self.right - self.left),
                y: Float(self.up - self.down),
                z: Float(self.forward - self.backward)
            )
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var keyReleased = false;
        
        presses.forEach{ press in
            if let key = press.key?.charactersIgnoringModifiers {
              switch (key) {
                case "e":
                  self.forward = 0
                  keyReleased = true
                  break;

                case "d":
                  self.backward = 0
                  keyReleased = true
                  break;

                case "s":
                  self.left = 0
                  keyReleased = true
                  break;

                case "f":
                  self.right = 0
                  keyReleased = true
                  break;

              case "t":
                  self.up = 0
                  keyReleased = true
                  break;

              case "g":
                  self.down = 0
                  keyReleased = true
                  break;

                default:
                  break;
              }
            }
        }

        if keyReleased {
            renderer.camera.setVelocity(
                x: Float(self.right - self.left),
                y: Float(self.up - self.down),
                z: Float(self.forward - self.backward)
            )
        }
    }
}
