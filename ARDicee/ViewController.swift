//
//  ViewController.swift
//  ARDicee
//
//  Created by Christopher Snyder on 11/27/18.
//  Copyright © 2018 MindTap. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var diceArray = [Die]()
    var showGrid = true
    
    @IBOutlet weak var showGridButton: UIBarButtonItem!
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        var configuration : ARConfiguration
//
//        // Create a session configuration
//        if ARWorldTrackingConfiguration.isSupported {
//            configuration = ARWorldTrackingConfiguration()
//            //print("AR World Tracking is supported: \(ARWorldTrackingConfiguration.isSupported)")
//        }
//        else  {
//            configuration = AROrientationTrackingConfiguration()
//        }

        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal, .vertical]
        //configuration.planeDetection = [.horizontal]
        
        
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
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                addDie(atLocation: hitResult)
            }
            
        }
    }
    
    func addDie(atLocation location : ARHitTestResult){
        let die = Die(withFinalLocation: SCNVector3(x: location.worldTransform.columns.3.x,
                                                    y: location.worldTransform.columns.3.y,
                                                    z: location.worldTransform.columns.3.z))
        diceArray.append(die)
        sceneView.scene.rootNode.addChildNode(die)
        
        die.roll()
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for die in diceArray {
                die.roll()
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func resetAll(_ sender: UIBarButtonItem) {
        removeAllDice()
    }
    
    
    func removeAllDice(){
        if !diceArray.isEmpty {
            for die in diceArray {
                die.removeFromParentNode()
            }
            diceArray.removeAll()
        }
    }
    
    @IBAction func hideShowGrid(_ sender: UIBarButtonItem) {
        showGrid = !showGrid
        showGridButton.image = UIImage(named: showGrid ? "glasses.png" : "sunglasses.png")
        
        for scnNode in self.sceneView.scene.rootNode.childNodes {
            for childNode in scnNode.childNodes {
                if let gridNode = childNode as? Grid {
                    gridNode.opacity = showGrid ? 1 : 0
//                    let fadeOut = SCNAction.customAction(duration: 5) { (node, elapsedTime) -> () in
//                        node.opacity = 1 - elapsedTime / 5
//                    }
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        gridNode.runAction(fadeOut)
//                    }
                    
                    
                    //gridNode.visibility(isVisible: !gridNode.isVisible)
                    //gridNode.visibility(isVisible: showGrid)
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let grid = Grid(withPlaneAnchor: planeAnchor)
        grid.opacity = showGrid ? 1 : 0
        node.addChildNode(grid)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        for childNode in node.childNodes {
            if let gridNode = childNode as? Grid {
                if gridNode.anchor.identifier == anchor.identifier {
                    //if we have found the Grid created by this anchor update it
                    gridNode.update(withAnchor: planeAnchor)
                }
            }
        }
    }
    
    // MARK: - Plane rendering methods
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
