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
    var scaleFactor = SCNVector3(0.5, 0.5, 0.5)
    
    override init() {
        // Create a new scene
        let pojectileScene = SCNScene(named: "art.scnassets/ProjectileModel.dae")!
        projectileChilds = pojectileScene.rootNode.childNodes
        
        super.init()
        
        for childNode in projectileChilds {
            self.addChildNode(childNode as SCNNode)
        }
        
        self.scale = scaleFactor
        self.position = SCNVector3(0.0, 3, 0.0)
        
//        let min = self.projectileChilds[2].boundingBox.min
//        let max = self.projectileChilds[2].boundingBox.max
//        let pHeight = CGFloat(max.y - min.y)
//        let pRadius = CGFloat((max.x - min.x) / 2)
//        let projectileGeo = SCNCylinder(radius: pRadius, height: pHeight)
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self))
        self.physicsBody!.categoryBitMask = ViewController.colliderCategory.projectile.rawValue
        
        if #available(iOS 9.0, *) {
            self.physicsBody!.contactTestBitMask = ViewController.colliderCategory.ground.rawValue | ViewController.colliderCategory.tank.rawValue
        } else {
            self.physicsBody!.collisionBitMask = ViewController.colliderCategory.ground.rawValue | ViewController.colliderCategory.tank.rawValue
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
