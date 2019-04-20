//
//  Projectile.swift
//  TanksAR
//
//  Created by Tensor Guest on 19.04.2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Projectile : SCNNode {
    var projectileChilds: [SCNNode]
    var projectilePosition: SCNVector3
    let direction: SCNVector3
    var boardSize = CGSize(width: 0.3, height: 0.54)
    var scaleFactor = SCNVector3(0.05, 0.05, 0.05)
    
    init(initialPosition: SCNVector3, initialDirection: SCNVector3) {
        // Create a new scene
        let pojectileScene = SCNScene(named: "art.scnassets/ProjectileModel.dae")!
        projectileChilds = pojectileScene.rootNode.childNodes
        projectilePosition = initialPosition
        direction = initialDirection
        
        super.init()
        
        for childNode in projectileChilds {
            self.addChildNode(childNode as SCNNode)
        }
        
        self.scale = scaleFactor
        self.position = SCNVector3(0.3, 0.3, 0.3)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: projectileGeo, options: nil))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
