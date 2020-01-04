//
//  ViewController.swift
//  ARMeasuring
//
//  Created by Livia Vasconcelos on 04/01/20.
//  Copyright © 2020 Livia Vasconcelos. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                  ARSCNDebugOptions.showFeaturePoints]
        sceneView.session.run(configuration)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView    = sender.view as? ARSCNView else { return }
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        let camera    = currentFrame.camera
        let transform = camera.transform
        
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.1
        
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.005))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        sphere.simdTransform = modifiedMatrix
        
        self.sceneView.scene.rootNode.addChildNode(sphere)
    }

}

