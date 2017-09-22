//
//  ViewController.swift
//  ARPortal
//
//  Created by Juan Ferreira on 9/16/17.
//  Copyright © 2017 juanferreira. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // 2d screen touch location
            let touchLocation = touch.location(in: sceneView)
            
            // 3d coordinate corresponding to the 2d coordinate that we got from touching the screen.
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)

            if let hitResult = results.first {
                let scene = SCNScene(named: "art.scnassets/portal.scn")
                
                if let portalNode = scene?.rootNode.childNode(withName: "portal", recursively: true) {
                    portalNode.position = SCNVector3Make(
                        hitResult.worldTransform.columns.3.x,
                        hitResult.worldTransform.columns.3.y + 0.05,
                        hitResult.worldTransform.columns.3.z - 1
                    )
                    
                    sceneView.scene.rootNode.addChildNode(portalNode)
                }
            }
        }
    }
    
    // Renderer method is called when horizontal plane has been detected
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            
            // Create plane geometry
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            // Create material for plane
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/textures/grid.png")
            
            plane.materials = [gridMaterial]
            
            // Create plane node with plane geometry
            let planeNode = SCNNode(geometry: plane)
            
            // set plane position of the plane geometry to the plane anchor
            planeNode.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
            
            // when a plane is created it's in xy plane instead of xz plane, so we need to rotate it along x axis
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            
            node.addChildNode(planeNode)
        }
    }
}
