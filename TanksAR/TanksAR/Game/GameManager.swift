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

class GameManager : TankServiceDelegate {
    public var delegate : GameManagerDelegate?
    var gameBoard: GameBoard!
    var sceneView: ARSCNView!
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
    func setupLevel() {
        let boardSize = setupBoard()
        //let bodyGeo = SCNPlane(width: CGFloat(boardSize.x), height: CGFloat(boardSize.y))
        //gameBoard.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: bodyGeo, options: nil))
        //if( )
        setupTank()
        //tank.boardSize = boardSize
        //projectile.boardSize = boardSize
        //tank.rescale(size: boardSize)
    }
    
    func setupTank() {
//        tank.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: tank))
//        tank.physicsBody!.categoryBitMask = ViewController.colliderCategory.tank.rawValue
//        if #available(iOS 9.0, *) {
//            tank.physicsBody!.contactTestBitMask = ViewController.colliderCategory.projectile.rawValue
//        } else {
//            tank.physicsBody!.collisionBitMask = ViewController.colliderCategory.projectile.rawValue
//        }
        gameBoard.addChildNode(tank)
    }
    
    var tank = Tank()
    
    func setupBoard() -> CGSize {
        
        let boardSize = CGSize(width: CGFloat(gameBoard.scale.x), height: CGFloat(gameBoard.scale.x * gameBoard.aspectRatio))
        gameBoard.anchor = BoardAnchor(transform: normalize(gameBoard.simdTransform), size: boardSize)
        sceneView.session.add(anchor: gameBoard.anchor!)
        
//        gameBoard.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: gameBoard))
//        gameBoard.physicsBody!.mass = 1000
//        gameBoard.physicsBody!.categoryBitMask = ViewController.colliderCategory.ground.rawValue
//
//        if #available(iOS 9.0, *) {
//            gameBoard.physicsBody!.contactTestBitMask = ViewController.colliderCategory.projectile.rawValue
//        } else {
//            gameBoard.physicsBody!.collisionBitMask = ViewController.colliderCategory.projectile.rawValue
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sceneView.session.getCurrentWorldMap { (worldMap, error) in
                self.sendWorld(worldMap: worldMap!)
            }
        }

        return boardSize
    }
    
    var projectile = Projectile()
    
    func createTrail() -> SCNNode {
        let trail = SCNParticleSystem(named: "Test.scnp", inDirectory: nil)!
        trail.particleSize = 0.005
        trail.particleLifeSpan = 0.005
        let node = SCNNode()
        node.addParticleSystem(trail)
        return node
    }
    
    func fire() {
        //let cannonPosition = tank.tanksChilds[2].childNode(withName: "Cannon", recursively: true)?.geometry?.boundingBox.max
        projectile.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: projectile))
        projectile.physicsBody!.categoryBitMask = ViewController.colliderCategory.projectile.rawValue
        if #available(iOS 9.0, *) {
            projectile.physicsBody!.contactTestBitMask = ViewController.colliderCategory.ground.rawValue | ViewController.colliderCategory.tank.rawValue
        } else {
            projectile.physicsBody!.collisionBitMask = ViewController.colliderCategory.ground.rawValue | ViewController.colliderCategory.tank.rawValue
        }
        //projectile = Projectile(initialPosition: cannonPosition!, initialDirection: SCNVector3(1.0, 0.0, 0.0))
        gameBoard.addChildNode(projectile)
        
        let trailEmitter = createTrail()
        trailEmitter.scale = SCNVector3(0.1, 0.1, 0.1)
        trailEmitter.position = SCNVector3(0.0, 0.5, 0.0)
        let action = SCNAction.sequence([SCNAction.scale(by: 5, duration: 10)])
        trailEmitter.runAction(action)
        gameBoard.addChildNode(trailEmitter)
    }

    
    func rotateBarrel(orientation: CGPoint) -> Double {
        rotate(orientation: orientation)
        return tank.cannonAngle
    }
    
    func moveTank(orientation: CGPoint) {
        move(orientation: orientation)
    }
    
    func move(orientation: CGPoint) {
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
            delegate?.didTankMovementReceived(vector: vector)
        case .barrelMovement(let vector):
            delegate?.didBarrelMovementReceived(vector: vector)
        }
    }
    
    func didDataReceived(url : URL, fromPeer peerID : MCPeerID) {
        let data = try! Data(contentsOf: url)
        let mapUnarchived = self.unarchive(worldMapData: data)
        delegate?.didWorldReceieved(worldMap: mapUnarchived!)
    }
}
