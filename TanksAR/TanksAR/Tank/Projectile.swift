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
    var projectilePosition: SCNVector3?
    var direction: SCNVector3?
    var boardSize = CGSize(width: 0.3, height: 0.54)
    var scaleFactor = SCNVector3(0.05, 0.05, 0.05)
    
    let velocity: Double = 300.0
    
//    init(initialPosition: SCNVector3, initialDirection: SCNVector3) {
    init(tank: Tank) {
        // Create a new scene
        let pojectileScene = SCNScene(named: "art.scnassets/ProjectileModel.dae")!
        projectileChilds = pojectileScene.rootNode.childNodes
        
        
//        projectilePosition = initialPosition
//        direction = initialDirection
//        direction!.x *= Float(velocity)
//        direction!.y *= Float(velocity)
//        direction!.z *= Float(velocity)
        

        direction = SCNVector3( Float(0.0), Float(0.0), Float(-10.0) )
        super.init()
        
        for childNode in projectileChilds {
            self.addChildNode(childNode as SCNNode)
        }
        
        self.scale = scaleFactor
        
        let min = projectileChilds[2].boundingBox.min
        let max = projectileChilds[2].boundingBox.max
        let pHeight = CGFloat(max.y - min.y)
        let pRadius = CGFloat((max.x - min.x) / 2)
        let projectileGeo = SCNCylinder(radius: pRadius, height: pHeight)
        
        self.position = tank.position
        self.eulerAngles.y = Float(tank.turretAngle + tank.tankRotateAngle)
        self.eulerAngles.x = -Float(tank.cannonAngle - Double.pi/2.0)
        
        let cannonLenght = Float(2.0*(tank.tanksChilds[2].childNode(withName: "Cannon", recursively: true)?.geometry?.boundingSphere.radius)!)
        let xTranslate = Double(2.0)
        let yTranslate = Double(2.0)
        let zTranslate = Double(2.0)
        let translateCannonGlobal = SCNVector3( xTranslate*sin(tank.turretAngle + tank.tankRotateAngle), yTranslate, zTranslate*cos(tank.turretAngle + tank.tankRotateAngle) )
        let scale: Float = 0.05
        
        self.position.x += (translateCannonGlobal.x + cannonLenght*Float(cos(tank.cannonAngle)*sin(tank.turretAngle + tank.tankRotateAngle)))*scale
        self.position.y += (translateCannonGlobal.y + cannonLenght*Float(sin(tank.cannonAngle)))*scale
        self.position.z += (translateCannonGlobal.z + cannonLenght*Float(cos(tank.cannonAngle)*cos(tank.turretAngle + tank.tankRotateAngle)))*scale
        
        direction = SCNVector3( Float(velocity*cos(tank.cannonAngle)*sin(tank.turretAngle + tank.tankRotateAngle)), Float(velocity*sin(tank.cannonAngle)), Float(velocity*cos(tank.cannonAngle)*cos(tank.turretAngle + tank.tankRotateAngle)) )
        
        
//        let maxCannonPosition = tank.tanksChilds[2].childNode(withName: "Cannon", recursively: true)?.geometry?.boundingBox.max
//        let minCannonPosition = tank.tanksChilds[2].childNode(withName: "Cannon", recursively: true)?.geometry?.boundingBox.min

//        var worldPositionProjectile = tank.tanksChilds[2].childNode(withName: "Cannon", recursively: true)?.worldPosition
//        worldPositionProjectile?.x += maxCannonPosition!.x*scale
//        worldPositionProjectile?.y += maxCannonPosition!.y*scale
//        worldPositionProjectile?.z += maxCannonPosition!.z*scale
        
//        let frontCannonPosition = SCNVector3((maxCannonPosition!.x - minCannonPosition!.x) * scale / 2.0, maxCannonPosition!.y * scale, (maxCannonPosition!.z - minCannonPosition!.z) * scale / 2.0 )
        
//        self.position.x += frontCannonPosition.x
//        self.position.y += frontCannonPosition.y
//        self.position.z += frontCannonPosition.z
        
//        self.worldPosition = worldPositionProjectile!
        
        self.projectilePosition = self.position
        
        
        //self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: projectileGeo, options: nil))
        self.physicsBody?.mass = CGFloat(100.0)

        self.physicsBody?.applyForce(direction!, at: self.worldPosition, asImpulse: true)
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self))
        self.physicsBody!.categoryBitMask = ViewController.colliderCategory.projectile.rawValue
        
        if #available(iOS 9.0, *) {
            self.physicsBody!.contactTestBitMask = ViewController.colliderCategory.tank.rawValue | ViewController.colliderCategory.ground.rawValue
        } else {
            self.physicsBody!.collisionBitMask = ViewController.colliderCategory.tank.rawValue | ViewController.colliderCategory.ground.rawValue
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
