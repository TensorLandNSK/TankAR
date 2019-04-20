//
//  ViewContoller+Collisions.swift
//  TanksAR
//
//  Created by Хакатон on 20/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

extension ViewController : SCNPhysicsContactDelegate {
    struct colliderCategory {
        static let tank = 1 << 0
        static let projectile = 1 << 1
        static let ground = 1 << 2
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        gameManager.physicsWorld(world, didBegin: contact)
    }
    
//    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        if ( contact.nodeA.categoryBitMask == colliderCategory.ground.rawValue ) || ( contact.nodeB.categoryBitMask == colliderCategory.ground.rawValue ) {
//            print("Collision with ground")
//        } else if ( contact.nodeA.categoryBitMask == colliderCategory.projectile.rawValue ) {
//            contact.nodeA.removeFromParentNode()
//        } else if ( contact.nodeB.categoryBitMask == colliderCategory.projectile.rawValue ) {
//            contact.nodeB.removeFromParentNode()
//        }
//    }
}
