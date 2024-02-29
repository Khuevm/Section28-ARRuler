//
//  ViewController.swift
//  ARRuler
//
//  Created by Khue on 29/02/2024.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    private var dotNodes: [SCNNode] = []
    private var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dotNode in dotNodes {
                dotNode.removeFromParentNode()
            }
            textNode.removeFromParentNode()
            dotNodes.removeAll()
        }
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, types: .featurePoint)
        if let hitTest = results.first {
            addDot(at: hitTest)
        }
    }
    
    private func addDot(at hitTestResult: ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
                                      hitTestResult.worldTransform.columns.3.y,
                                      hitTestResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    private func calculate(){
        let startPoint = dotNodes[0]
        let endPoint = dotNodes[1]
        
        let distance = sqrt(
            pow(startPoint.position.x - endPoint.position.x, 2) +
            pow(startPoint.position.y - endPoint.position.y, 2) +
            pow(startPoint.position.z - endPoint.position.z, 2)
        )
        
        let centerPosition = SCNVector3(x: (startPoint.position.x + endPoint.position.x)/2,
                                        y: (startPoint.position.y + endPoint.position.y)/2,
                                        z: (startPoint.position.z + endPoint.position.z)/2)
        addText(text: "\(distance * 100) cm", position: centerPosition)
    }
    
    private func addText(text: String, position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = position
        textNode.scale = SCNVector3(x: 0.002, y: 0.002, z: 0.002)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
