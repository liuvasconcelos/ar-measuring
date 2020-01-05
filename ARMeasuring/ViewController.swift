//
//  ViewController.swift
//  ARMeasuring
//
//  Created by Livia Vasconcelos on 04/01/20.
//  Copyright © 2020 Livia Vasconcelos. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    var startingPosition: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                  ARSCNDebugOptions.showFeaturePoints]
        sceneView.session.run(configuration)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
        
        sceneView.delegate = self
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView    = sender.view as? ARSCNView else { return }
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        if self.startingPosition != nil {
            self.startingPosition?.removeFromParentNode()
            self.startingPosition = nil
            return
        }
        
        let camera    = currentFrame.camera
        let transform = camera.transform
        
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.1
        
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.005))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        sphere.simdTransform = modifiedMatrix
        
        self.sceneView.scene.rootNode.addChildNode(sphere)
        
        startingPosition = sphere
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let startingPosition = self.startingPosition else { return }
        guard let pointOfView = self.sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        
        DispatchQueue.main.async {
            self.xLabel.text = String(format: "%.2f", xDistance) + "m"
            self.yLabel.text = String(format: "%.2f", yDistance) + "m"
            self.zLabel.text = String(format: "%.2f", zDistance) + "m"
            self.distance.text = String(format: "%.2f",
                                        self.distanceTravelled(x: xDistance, y: yDistance, z: zDistance)) + "m"
        }
        
    }
    
    func distanceTravelled(x: Float, y: Float, z: Float) -> Float {
        return (sqrtf(x*x + y*y + z*z))
    }
}

