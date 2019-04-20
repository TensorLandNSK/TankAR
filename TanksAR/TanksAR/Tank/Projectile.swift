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

class Projectile {
	
	var node: SCNNode
	
	init(_ node: SCNNode) {
		self.node = node
		node.name = "projetile"
		
	}
	
	static func spawnProjectile() -> Projectile {
		// 1
		let geometry = SCNSphere(radius: 0.005)
		
		geometry.materials.first?.diffuse.contents = UIColor.red
		
		// 4
		let geometryNode = SCNNode(geometry: geometry)
		geometryNode.physicsBody = SCNPhysicsBody.dynamic()
		
		
		// 5
		return Projectile(geometryNode)
	}
	
	func launchProjectile(position: SCNVector3, x: Float, y: Float, z: Float) {
		let force = SCNVector3(x: Float(x), y: Float(y) , z: z)
		
		// 4
		node.physicsBody?.applyForce(force, at: position, asImpulse: true)
//		node.categoryBitMask = CollisionCategories.projectile
//		node.physicsBody?.contactTestBitMask = CollisionCategories.gameboard
        
        if #available(iOS 9.0, *) {
            node.physicsBody!.contactTestBitMask = ViewController.colliderCategory.tank.rawValue | ViewController.colliderCategory.ground.rawValue
        } else {
            node.physicsBody!.collisionBitMask = ViewController.colliderCategory.tank.rawValue | ViewController.colliderCategory.ground.rawValue
        }
        
	}
}
