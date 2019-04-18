//
//  ViewController+GestureRecognizers.swift
//  TanksAR
//
//  Created by Антипов В.Б. on 18/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import UIKit
import ModelIO
import SceneKit.ModelIO


extension ViewController: UIGestureRecognizerDelegate {
	
	func setupRecognizers() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		let pinch = ThresholdPinchGestureRecognizer(target: self, action: #selector(handlePinch))
		let pan = ThresholdPanGestureRecognizer(target: self, action: #selector(handlePan))
		let rotation = ThresholdRotationGestureRecognizer(target: self, action: #selector(handleRotation))
		
		let recognizers = [tap, pinch, pan, rotation]
		
		sceneView.gestureRecognizers?.append(contentsOf: recognizers)
		
		for r in recognizers {
			r.delegate = self
		}
	}
	
	// MARK: - UI Gestures and Touches
	@IBAction func handleTap(_ gesture: UITapGestureRecognizer) {
		guard gesture.state == .ended else { return }
		
		switch sessionState {
		case .placingBoard, .adjustingBoard:
			if !gameBoard.isBorderHidden {
				sessionState = .setupLevel
			}
		case .gameInProgress:
			// gameManager?.handleTouch(.tapped)
			break
		default:
			break
		}
	}
	
	@IBAction func handlePinch(_ gesture: ThresholdPinchGestureRecognizer) {
		guard canAdjustBoard else { return }
		
		sessionState = .adjustingBoard
		
		switch gesture.state {
		case .changed where gesture.isThresholdExceeded:
			gameBoard.scale(by: Float(gesture.scale))
			gesture.scale = 1
		default:
			break
		}
	}
	
	@IBAction func handleRotation(_ gesture: ThresholdRotationGestureRecognizer) {
		guard canAdjustBoard else { return }
		
		sessionState = .adjustingBoard
		
		switch gesture.state {
		case .changed where gesture.isThresholdExceeded:
			if gameBoard.eulerAngles.x > .pi / 2 {
				gameBoard.simdEulerAngles.y += Float(gesture.rotation)
			} else {
				gameBoard.simdEulerAngles.y -= Float(gesture.rotation)
			}
			gesture.rotation = 0
		default:
			break
		}
	}
	
	@IBAction func handlePan(_ gesture: ThresholdPanGestureRecognizer) {
		
		guard canAdjustBoard else { return }
		
		sessionState = .adjustingBoard
		
		let location = gesture.location(in: sceneView)
		let results = sceneView.hitTest(location, types: .existingPlane)
		guard let nearestPlane = results.first else {
			return
		}
		
		switch gesture.state {
		case .began:
			panOffset = nearestPlane.worldTransform.columns.3.xyz - gameBoard.simdWorldPosition
		case .changed:
			gameBoard.simdWorldPosition = nearestPlane.worldTransform.columns.3.xyz - panOffset
		default:
			break
		}
	}
	
	@IBAction func handleLongPress(_: UILongPressGestureRecognizer) {
		guard canAdjustBoard else { return }
		
		sessionState = .adjustingBoard
		gameBoard.useDefaultScale()
	}
	
	func gestureRecognizer(_ first: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith second: UIGestureRecognizer) -> Bool {
		if first is UIRotationGestureRecognizer && second is UIPinchGestureRecognizer {
			return true
		} else if first is UIRotationGestureRecognizer && second is UIPanGestureRecognizer {
			return true
		} else if first is UIPinchGestureRecognizer && second is UIRotationGestureRecognizer {
			return true
		} else if first is UIPinchGestureRecognizer && second is UIPanGestureRecognizer {
			return true
		} else if first is UIPanGestureRecognizer && second is UIPinchGestureRecognizer {
			return true
		} else if first is UIPanGestureRecognizer && second is UIRotationGestureRecognizer {
			return true
		}
		return false
	}
}
