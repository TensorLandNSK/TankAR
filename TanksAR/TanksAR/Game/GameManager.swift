//
//  GameManager.swift
//  TanksAR
//
//  Created by tensor_guest on 20/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import ARKit
import AVFoundation

class GameManager : TankServiceDelegate {
    public var delegate : GameManagerDelegate?
    var gameBoard: GameBoard!
    var sceneView: ARSCNView!
    var hostTank = Tank()
    var enemyTank = Tank()
    let shotTank = AudioControl(forResource: "shotTank")
    let hit = AudioControl(forResource: "hitForEnemy")
    //let explodeTank = AudioControl(forResource: "explodeTank")
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
    func setupLevel(remoteGameBoard : GameBoard?) {
        let boardSize: CGSize
        if let board = remoteGameBoard {
            gameBoard = board
            boardSize = CGSize(width: CGFloat(gameBoard.scale.x), height: CGFloat(gameBoard.scale.x * gameBoard.aspectRatio))
        } else {
            boardSize = setupBoard()
        }

        let hostPosition = SCNVector3(0, 0, ((Float(boardSize.height) * gameBoard.aspectRatio) / 2))
        
        let enemyPosition = SCNVector3(0, 0, -((Float(boardSize.height) * gameBoard.aspectRatio) / 2))
        
        if remoteGameBoard == nil {
            setupHostTank(position: hostPosition, rotation: 90)
            setupEnemyTanks(position: enemyPosition, rotation: -90)
        } else {
            setupHostTank(position: enemyPosition, rotation: -90)
            setupEnemyTanks(position: hostPosition, rotation: 90)
        }
         
       

    }
    
    func setupBoard() -> CGSize {
        
        let boardSize = CGSize(width: CGFloat(gameBoard.scale.x), height: CGFloat(gameBoard.scale.x * gameBoard.aspectRatio))
        gameBoard.anchor = BoardAnchor(transform: normalize(gameBoard.simdTransform), size: boardSize)
        sceneView.session.add(anchor: gameBoard.anchor!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sceneView.session.getCurrentWorldMap { (worldMap, error) in
                self.sendWorld(worldMap: worldMap!)
            }
        }
        return boardSize
    }
    
    func setupHostTank(position : SCNVector3, rotation: Double) {
        hostTank.position = position
        hostTank.rotate(angle: rotation)
        self.gameBoard.addChildNode(hostTank)
    }
    
    func setupEnemyTanks(position : SCNVector3, rotation: Double) {
        enemyTank.position = position
        enemyTank.rotate(angle: rotation)
        self.gameBoard.addChildNode(enemyTank)
    }
    
    var projectile: Projectile?
    
    func fire() {
        fire(tank: hostTank)
        shotTank.onPlay(volume: 1)
        sendLaunchProjectile()
    }
    
    private func fire(tank: Tank) {
        
		let proj = fire(vel: 5, tank: tank)
		
        self.sceneView.scene.rootNode.addChildNode(proj.node)
    }
	
	func fire(vel: Float, tank: Tank) -> Projectile {
		
		let barrel = tank.tanksChilds[0].childNodes[0]//.childNode(withName: "Cannon", recursively: true)!
		
		let proj = Projectile.spawnProjectile()
		let floats = simd_float3(barrel.worldUp)
		let normalizedBarrelFront = simd.normalize(floats) * (1.0)
		proj.node.simdPosition = barrel.simdWorldPosition //+ normalizedBarrelFront
		
        let name = tank == hostTank ? "host" : "enemy"
        
        proj.launchProjectile(position: SCNVector3Zero, x: normalizedBarrelFront.x * vel, y: normalizedBarrelFront.y * vel, z: normalizedBarrelFront.z * vel, name: name)

		return proj
	}
    
    func createTrail(at: SCNVector3, name: String) {
        let trail = SCNParticleSystem(named: "FireExplosion.scnp", inDirectory: nil)!
        let node = SCNNode()
        node.addParticleSystem(trail)
        node.scale = SCNVector3(0.2, 0.2, 0.2)
        sceneView.scene.rootNode.addChildNode(node)
        node.worldPosition = at
        if name == "host" {
            hit.onPlay(volume: 1)
        } else if name == "enemy" {
            hit.onPlay(volume: 0.4)
        }
    }
    
    func rotateBarrel(orientation: CGPoint) -> Double {
        sendBarrelMovement(vector: orientation)
        return rotateBarrel(tank: hostTank, orientation: orientation)
    }
    
    private func rotateBarrel(tank: Tank, orientation: CGPoint) -> Double {
        rotate(orientation: orientation)
        return tank.cannonAngle
    }
    
    func moveTank(orientation: CGPoint) {
        sendTankMovement(vector: orientation)
        move(tank: hostTank, orientation: orientation)
    }
    
    private func move(tank: Tank, orientation: CGPoint) {
        let speed: Double = 0.005
        let angleSpeed: Double = 0.5
        
        var direction = SCNVector3(0.0, 0.0, 0.0)
        var angle: Double = 0.0
        if orientation.x > 0 {
            angle = angleSpeed
        }
        else if orientation.x < 0 {
            angle = -angleSpeed
        }
        
        if orientation.y > 0 {
            direction = SCNVector3(0.0, 0.0, speed)
        }
        else if orientation.y < 0 {
            direction = SCNVector3(0.0, 0.0, -speed)
        }
        tank.move(direction: direction)
        tank.rotate(angle: angle)
    }
    
    func rotate(orientation: CGPoint) {
        rotate(tank: hostTank, orientation: orientation)
    }
    
    private func rotate(tank : Tank, orientation: CGPoint) {
        let turretAngleSpeed: Double = 1.0 // Degree
        let cannonAngleSpeed: Double = 2.0 // Degree
        var turretAngle: Double
        var cannonAngle: Double
        if orientation.x > 0 {
            turretAngle = turretAngleSpeed
        }
        else if orientation.x < 0 {
            turretAngle = -turretAngleSpeed
        }
        else {
            turretAngle = 0.0
        }
        
        if orientation.y > 0 {
            cannonAngle = cannonAngleSpeed
        }
        else if orientation.y < 0 {
            cannonAngle = -cannonAngleSpeed
        }
        else {
            cannonAngle = 0.0
        }
        
        tank.adjustCannon(angle: cannonAngle)
        tank.rotateTurret(angle: turretAngle)
    }
    
    func archive(worldMap: ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: self.worldMapURL, options: [.atomic])
    }
    
    func unarchive(worldMapData data: Data) -> ARWorldMap? {
        guard let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
            let worldMap = unarchievedObject else { return nil }
        return worldMap
    }
    
    func retrieveWorldMapData(from url: URL) -> Data? {
        do {
            return try Data(contentsOf: self.worldMapURL)
        } catch {
            fatalError("Error retrieving world map data.")
        }
    }
    
    func sendWorld(worldMap: ARWorldMap) {
        do {
            try archive(worldMap: worldMap)
            TanksService.shared().sendData(url: worldMapURL)
        } catch {
            print(error)
        }
    }
    
    func sendLaunchProjectile() {
        let gameData = GameData.launchProjectile
        let encoder = JSONEncoder()
        let data = try! encoder.encode(gameData)
        TanksService.shared().sendData(data: data)
    }
    
    func sendTankMovement(vector: CGPoint) {
        let gameData = GameData.tankMovement(vector: vector)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(gameData)
        TanksService.shared().sendData(data: data)
    }
    
    func sendBarrelMovement(vector: CGPoint) {
        let gameData = GameData.barrelMovement(vector: vector)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(gameData)
        TanksService.shared().sendData(data: data)
    }
    
    func didDataReceived(data : Data, fromPeer peerID : MCPeerID) {
        let decoder = JSONDecoder()
        let gameData = try! decoder.decode(GameData.self, from: data)
        switch gameData {
        case .gameBoard(let url):
            let worldMap = self.retrieveWorldMapData(from: url)
            let mapUnarchived = self.unarchive(worldMapData: worldMap!)
            delegate?.didWorldReceieved(worldMap: mapUnarchived!)
        case .tankMovement(let vector):
            move(tank: enemyTank, orientation: vector)
        case .barrelMovement(let vector):
            rotate(tank: enemyTank, orientation: vector)
        case .launchProjectile:
            shotTank.onPlay(volume: 0.1)
            fire(tank: enemyTank)
        }
    }
    
    func didDataReceived(url : URL, fromPeer peerID : MCPeerID) {
        let data = try! Data(contentsOf: url)
        let mapUnarchived = self.unarchive(worldMapData: data)
        delegate?.didWorldReceieved(worldMap: mapUnarchived!)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if ( contact.nodeA.categoryBitMask == ViewController.colliderCategory.ground ) || ( contact.nodeB.categoryBitMask == ViewController.colliderCategory.ground ) {
            print("Collision with ground")
        } else if ( contact.nodeA.categoryBitMask == ViewController.colliderCategory.projectile ) && contact.nodeA.name == "host" {
            if contact.nodeB == enemyTank {
                createTrail(at: contact.contactPoint, name: "enemy" )
                contact.nodeA.removeFromParentNode()
//                contact.nodeA.geometry?.materials.first?.diffuse.contents = UIColor.green
//                NSLog("hit")
            }
        } else if ( contact.nodeB.categoryBitMask == ViewController.colliderCategory.projectile ) && contact.nodeB.name == "host"{
            if contact.nodeA == enemyTank {
                createTrail(at: contact.contactPoint, name: "enemy" )
                contact.nodeB.removeFromParentNode()
//                contact.nodeB.geometry?.materials.first?.diffuse.contents = UIColor.green
//                NSLog("hit")
            }
        } else if ( contact.nodeA.categoryBitMask == ViewController.colliderCategory.projectile ) && contact.nodeA.name == "enemy" {
            if contact.nodeB == hostTank {
                createTrail(at: contact.contactPoint, name: "host" )
                contact.nodeA.removeFromParentNode()
                //                contact.nodeA.geometry?.materials.first?.diffuse.contents = UIColor.green
                //                NSLog("hit")
            }
        } else if ( contact.nodeB.categoryBitMask == ViewController.colliderCategory.projectile ) && contact.nodeB.name == "enemy"{
            if contact.nodeA == hostTank {
                createTrail(at: contact.contactPoint, name: "host" )
                contact.nodeB.removeFromParentNode()
                //                contact.nodeB.geometry?.materials.first?.diffuse.contents = UIColor.green
                //                NSLog("hit")
            }
        }
    }
}
