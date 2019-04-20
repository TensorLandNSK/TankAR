//
//  ViewController.swift
//  TanksAR
//
//  Created by Антипов В.Б. on 18/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, RotateDelegate, FireDelegate {

    var projectile: Projectile?
    
    func fire() {
         projectile = Projectile(initialPosition: SCNVector3(0.1, 0.0, 0.5), initialDirection: SCNVector3(1.0, 0.0, 0.0))
        self.gameBoard.addChildNode(projectile!)
    }
    
    func rotate(orientation: CGPoint, sender: BarrelControl) {
        if sender == barrelControl {
            rotate(orientation: orientation)
            angleDisplay.angle = CGFloat(tank.cannonAngle)
        } else if sender == barrelControlTank {
            move(orientation: orientation)
        }
    }
    
    func move(orientation: CGPoint) {
        tank.move(direction: SCNVector3(0.0, 0.0, 0.005))
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
    
    /*
     angleDisplay.angle отвечает за угол стрелки показателя наклона дула в радианах
    */
    
	
	@IBOutlet var sceneView: ARSCNView!
	
	var gameBoard = GameBoard()
    
    var gameManager = GameManager()
	
	var targetWorldMap: ARWorldMap?

    @IBOutlet var barrelControl: BarrelControl!
    
    @IBOutlet var fireControl: FireControl!
    
    @IBOutlet var barrelControlTank: BarrelControl!
    
    @IBOutlet var angleDisplay: AngleDisplay!
    
    var sessionState: SessionState = .setup {
		didSet {
			guard oldValue != sessionState else { return }
			configureARSession()
		}
	}
    
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
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
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        gameManager.delegate = self
		
		// Set the view's delegate
		sceneView.delegate = self
		
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		sceneView.session.delegate = self

		// Create a new scene
		let scene = SCNScene(named: "art.scnassets/ship.scn")!
		
		// Set the scene to the view
		sceneView.scene = scene
		
		sceneView.scene.rootNode.addChildNode(gameBoard)
		sessionState = .lookingForSurface
		setupRecognizers()
        
        barrelControl.delegate = self
        fireControl.delegateFire = self
        barrelControlTank.delegate = self
        TanksService.shared().delegate = gameManager

	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Create a session configuration
		let configuration = ARWorldTrackingConfiguration()
		
		// Run the view's session
		sceneView.session.run(configuration)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Pause the view's session
		sceneView.session.pause()
	}
    
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
        self.gameBoard.addChildNode(tank)
    }
    
	var tank = Tank()
	
	func setupBoard() -> CGSize {
		
		let boardSize = CGSize(width: CGFloat(gameBoard.scale.x), height: CGFloat(gameBoard.scale.x * gameBoard.aspectRatio))
		gameBoard.anchor = BoardAnchor(transform: normalize(gameBoard.simdTransform), size: boardSize)
		sceneView.session.add(anchor: gameBoard.anchor!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sceneView.session.getCurrentWorldMap { (worldMap, error) in
                self.gameManager.sendWorld(worldMap: worldMap!)
            }
        }
        

		
		return boardSize
	}
	
	var panOffset = float3()

	// Override to create and configure nodes for anchors added to the view's session.
	func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
		if anchor == gameBoard.anchor {
			// If board anchor was added, setup the level.
			DispatchQueue.main.async {
				if self.sessionState == .localizingToBoard {
					self.sessionState = .setupLevel
				}
			}
			
			// We already created a node for the board anchor
			return gameBoard
		} else {
			// Ignore all other anchors
			return nil
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		if let boardAnchor = anchor as? BoardAnchor {
			// Update the game board's scale from the board anchor
			// The transform will have already been updated - without the scale
			node.simdScale = float3(Float(boardAnchor.size.width))
		}
	}
	
	// MARK: - ARSCNViewDelegate
	
	func session(_: ARSession, didFailWithError _: Error) {
		// Present an error message to the user
		
	}
	
	func sessionWasInterrupted(_: ARSession) {
		// Inform the user that the session has been interrupted, for example, by presenting an overlay
		
	}
	
	func sessionInterruptionEnded(_: ARSession) {
		// Reset tracking and/or remove existing anchors if consistent tracking is required
		
	}
}

// MARK: - ARSessionDelegate
extension ViewController: ARSessionDelegate {
	
	func session(_: ARSession, didUpdate frame: ARFrame) {
		updateGameBoard(frame: frame)
	}
}

extension ViewController: GameManagerDelegate {
    func didWorldReceieved(worldMap: ARWorldMap) {
        targetWorldMap = worldMap
        sessionState = .localizingToBoard
    }
}
