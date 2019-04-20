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
    
    func collisions() {
        gameBoard.physicsBody = SCNPhysicsBody.kinematic()
        gameBoard.physicsBody!.categoryBitMask = colliderCategory.ground.rawValue
        
        if #available(iOS 9.0, *) {
            gameBoard.physicsBody!.contactTestBitMask = colliderCategory.projectile.rawValue
        } else {
            gameBoard.physicsBody!.collisionBitMask = colliderCategory.projectile.rawValue
        }
        
        let min = projectile?.projectileChilds[2].boundingBox.min
        let max = projectile?.projectileChilds[2].boundingBox.max
        let pHeight = CGFloat(max!.y - min!.y)
        let pRadius = CGFloat((max!.x - min!.x) / 2)
        let projectileGeo = SCNCylinder(radius: pRadius, height: pHeight)
        
        projectile?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: projectileGeo, options: nil))
        projectile?.physicsBody!.categoryBitMask = colliderCategory.projectile.rawValue
        
    }
    
}
