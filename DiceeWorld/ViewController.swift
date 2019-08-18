//  ViewController.swift
//  DiceeWorld
//
//  Created by Chaker on 7/28/19.
//  Copyright © 2019 Chaker Saloumi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    //MARK: - View Life cycle methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //enables light in the sceneview
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        //detect a plane
        configuration.planeDetection = .horizontal // it is an enum

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    //MARK: - Dice Rendering methods
    
    //Function to add a dice
    func addDice(atLocation location: ARHitTestResult){
        // create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
            // give the location of the touch
            // 4 columns and 4 rows
            diceNode.position = SCNVector3(x: location.worldTransform.columns.3.x,
                                           // add radius to place the dice above the plane completely
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z)
            //add the dice added to the array
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
            
        }
        
    }
    
    
    // Add a dice on the plane when the user touches the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // we check if it contains an object
        if let touch = touches.first{
            //set the touch location
            let touchLocation = touch.location(in: sceneView) // it take an scn node that is our sceneView
            // convert the 2D location into a 3D locagtion
            // type is type of result we are looking for .existingPlane
            // it respects our plane limited size
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            // check if results array is not empty and place the dice this location
            if let hitResult = results.first {
                //add a dice
              addDice(atLocation: hitResult)
                
        }
            
    }
        
    }
    

    
    //Function to roll dice in SCNView
    func roll(dice: SCNNode){
        //create a random number 1 to 4
        //rotate along the x axis and z axis and all face to be equal and cast into float
        //the z component is similar
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        //do the action
        //multiply thr angles by 5 to make it spin more
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
        
    }
    
    //Function to roll all dices in the View
    func rollAllDices(){
        
        if !diceArray.isEmpty{
            //we check that the array is not empty
            for dice in diceArray {
                // we roll the dice here
                roll(dice: dice)
            }
        }
    }
    
    // Button to roll all dices
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAllDices()
    }
    
    //Remove all dices from parent node
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        //check that the array is not empty
        if !diceArray.isEmpty{
            //remove the nodes from parent nodes
            for dice in diceArray{
                dice.removeFromParentNode()
            }
            
        }
    }
    
    //When shaking it will roll all dices
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAllDices()
    }
    

    
    //MARK: - ARSCN View Delegate methods
    //Will tell us the size of the horizontal plane in Anchor which is a real world position
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            // we check that anchor is a surface not an object
            //we try to downcast the anchor variable to an ARPlaneAnchor
            guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
           let planeNode =  createPlane(withPlaneAnchor: planeAnchor)

            //then add the node as a child
            node.addChildNode(planeNode)
            
    
    }
    
    //MARK: - Plane Rendering Methods
    //create a plane and returns it as SCNNode to add it
    func  createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor)-> SCNNode{
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        
        //give the position same as anchor
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        // rotate plane note by 90 degrees (rad) to transform it into a horizontal plane using this function onlz
        //along the x component
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2,1 , 0 , 0)
        //create material for the plane like for the moon
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        // We set the plane materials to the grid one
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        
        return planeNode
    }
    
    
    
    
}
