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

    func fire() {
        gameManager.fire()
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
    
    @IBOutlet weak var hostHPBar: UIProgressView!
    
    @IBOutlet weak var enemyHPBar: UIProgressView!
    
    var sessionState: SessionState = .setup {
		didSet {
			guard oldValue != sessionState else { return }
			configureARSession()
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
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.speed = 0.05
//        sceneView.scene.physicsWorld.gravity = SCNVector3( 0.0, 0.0, 0.0 )
        
		sessionState = .lookingForSurface
		setupRecognizers()
        
        barrelControl.delegate = self
        fireControl.delegateFire = self
        barrelControlTank.delegate = self
        TanksService.shared().delegate = gameManager
        gameManager.gameBoard = gameBoard
        gameManager.sceneView = sceneView
        
        enemyHPBar.transform = CGAffineTransform(rotationAngle: .pi)
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
    
    func rotate(orientation: CGPoint, sender: BarrelControl) {
        if sender == barrelControl {
            let angle = gameManager.rotateBarrel(orientation: orientation)
            angleDisplay.angle = CGFloat(angle)
        } else if sender == barrelControlTank {
            gameManager.moveTank(orientation: orientation)
        }
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
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @objc func showMain() {
        self.performSegue(withIdentifier: "showMain", sender: nil)
    }
    
    func onEndGame(isWinner : Bool){
        angleDisplay.isHidden = true
        barrelControl.isHidden = true
        barrelControlTank.isHidden = true
        fireControl.isHidden = true
        
        statusLabel.textColor = (isWinner) ? .green : .red
        statusLabel.text? = (isWinner) ? "YOU WON" : "ENEMY WON"
        statusLabel.isHidden = false
        
        let gs = UITapGestureRecognizer(target: self, action: #selector(showMain))
        sceneView.addGestureRecognizer(gs)
        
        TanksService.shared().serviceSession.disconnect()
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
    
    func didTankMovementReceived(vector: CGPoint) {
        
    }
    
    func didBarrelMovementReceived(vector: CGPoint) {
        
    }
    
    func didHitReceived() {
        hostHPBar.setProgress(gameManager.hostTank.hp, animated: true)
        enemyHPBar.setProgress(gameManager.enemyTank.hp, animated: true)
        if hostHPBar.progress == 0 {
            onEndGame(isWinner : false)
        } else if enemyHPBar.progress == 0 {
            onEndGame(isWinner : true)
        }
    }
}
