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
    enum colliderCategory: Int {
        case tank = 1
        case projectile
        case ground
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if ( contact.nodeA.categoryBitMask == colliderCategory.ground.rawValue ) || ( contact.nodeB.categoryBitMask == colliderCategory.ground.rawValue ) {
            print("Collision with ground")
        } else {
            print("Collisions without ground")
        }
    }
}
