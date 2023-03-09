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
class RenderViewController: UIViewController {
    
    var renderer: RenderDelegate!
    
    var prevPoint: CGPoint?
    
    var forward = 0
    var backward = 0
    var left = 0
    var right = 0
    var up = 0
    var down = 0
    
    override func loadView() {
        let mtkView = MTKView()
        self.view = mtkView

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported")
            return
        }
        
        mtkView.device = defaultDevice
        
        guard let renderer = try? RenderDelegate(metalKitView: mtkView, lights: Lights.shared) else {
            print("Renderer cannot be initialized")
            return
        }
        
        self.renderer = renderer
        
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
                
        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        swipeGestureRecognizer.allowedScrollTypesMask = .continuous

        mtkView.addGestureRecognizer(swipeGestureRecognizer);
        
        mtkView.backgroundColor = UIColor.black
        mtkView.preferredFramesPerSecond = 60
        mtkView.isPaused = false

        mtkView.delegate = renderer
    }

    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: self.view)
        
        if sender.state != .began {
            if let prevPoint = self.prevPoint {
                let xDelta = -Float(point.x - prevPoint.x);
                let yDelta = -Float(point.y - prevPoint.y);
                let sensitivity: Float = 0.1;

                Renderer.shared.camera.updateLookAt(yawChange: xDelta * sensitivity, pitchChange: yDelta * sensitivity);
            }
        }
        
        self.prevPoint = point
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            let point = touch.preciseLocation(in: view)
            let prevPoint = touch.precisePreviousLocation(in: view)

            let xDelta = -Float(point.x - prevPoint.x);
            let yDelta = -Float(point.y - prevPoint.y);
            let sensitivity: Float = 0.1;

            Renderer.shared.camera.updateLookAt(yawChange: xDelta * sensitivity, pitchChange: yDelta * sensitivity);
        }
    }
    
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
            Renderer.shared.camera.setMoveDirection(
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
            Renderer.shared.camera.setMoveDirection(
                x: Float(self.right - self.left),
                y: Float(self.up - self.down),
                z: Float(self.forward - self.backward)
            )
        }
    }
}
