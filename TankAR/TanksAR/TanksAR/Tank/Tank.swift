//
//  Tank.swift
//  TanksAR
//
//  Created by Tensor Guest on 19.04.2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Tank : SCNNode {
    var tanksChilds: [SCNNode]
    let scaleFactor = SCNVector3(0.05, 0.05, 0.05)
    override init() {
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/TankModel.dae")!
        tanksChilds = scene.rootNode.childNodes
        
        super.init()
        
        for childNode in tanksChilds {
            self.addChildNode(childNode as SCNNode)
            //childNode.geometry?.materials = [newMaterial]
        }
        self.scale = scaleFactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
