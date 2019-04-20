//
//  ViewController+Base.swift
//  TanksAR
//
//  Created by Антипов В.Б. on 18/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//
import ARKit


extension ViewController {
	var attemptingBoardPlacement: Bool {
		return sessionState == .lookingForSurface || sessionState == .placingBoard
	}
	
	var canAdjustBoard: Bool {
		return sessionState == .placingBoard || sessionState == .adjustingBoard
	}
	
	var screenCenter: CGPoint {
		let bounds = sceneView.bounds
		return CGPoint(x: bounds.midX, y: bounds.midY)
	}
	
	// MARK: - Board management
	func updateGameBoard(frame: ARFrame) {
		
		if sessionState == .setupLevel {
			// this will advance the session state
			setupLevel()
            sessionState = .gameInProgress
			return
		}
		
		// Only automatically update board when looking for surface or placing board
		guard attemptingBoardPlacement else {
			return
		}
		
		// Make sure this is only run on the render thread
		
		if gameBoard.parent == nil {
			sceneView.scene.rootNode.addChildNode(gameBoard)
		}
		
		// Perform hit testing only when ARKit tracking is in a good state.
		if case .normal = frame.camera.trackingState {
			
			if let result = sceneView.hitTest(screenCenter, types: [.estimatedHorizontalPlane, .existingPlaneUsingExtent]).first {
				// Ignore results that are too close to the camera when initially placing
				guard result.distance > 0.5 || sessionState == .placingBoard else { return }
				
				sessionState = .placingBoard
				gameBoard.update(with: result, camera: frame.camera)
			} else {
				sessionState = .lookingForSurface
				if !gameBoard.isBorderHidden {
					gameBoard.hideBorder()
				}
			}
		}
	}
	
	func configureARSession() {
		let configuration = ARWorldTrackingConfiguration()
		configuration.isAutoFocusEnabled = true // UserDefaults.standard.autoFocus
		let options: ARSession.RunOptions
		switch sessionState {
		case .setup:
			// in setup
			sceneView.session.pause()
			return
		case .lookingForSurface, .waitingForBoard:
			// both server and client, go ahead and start tracking the world
			configuration.planeDetection = [.horizontal]
			options = [.resetTracking, .removeExistingAnchors]
			
			// Only reset session if not already running
			if sceneView.isPlaying {
				return
			}
		case .placingBoard, .adjustingBoard:
			// we've found at least one surface, but should keep looking.
			// so no change to the running session
			return
		case .localizingToBoard:
			guard let targetWorldMap = targetWorldMap else { return }
			configuration.initialWorldMap = targetWorldMap
			configuration.planeDetection = [.horizontal]
			options = [.resetTracking, .removeExistingAnchors]
			gameBoard.anchor = targetWorldMap.boardAnchor
			if let boardAnchor = gameBoard.anchor {
				gameBoard.simdTransform = boardAnchor.transform
				gameBoard.simdScale = float3(Float(boardAnchor.size.width))
				//setupTanks(boardSize: boardAnchor.size)
			}
			
			sessionState = .gameInProgress
			//gameBoard.hideBorder(duration: 0)
			
		case .setupLevel:
			// more init
			return
		case .gameInProgress:
			// The game is in progress, no change to the running session
			return
		}
		
		// Turning light estimation off to test PBR on SceneKit file
		configuration.isLightEstimationEnabled = false
		
		sceneView.session.run(configuration, options: options)
	}
}
