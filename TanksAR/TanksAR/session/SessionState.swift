//
//  SessionState.swift
//  ARTanks
//
//  Created by Полин К.С. on 15.03.2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation

enum SessionState {
	case setup
	case lookingForSurface
	case adjustingBoard
	case placingBoard
	case waitingForBoard
	case localizingToBoard
	case setupLevel
	case gameInProgress
	
	var localizedInstruction: String? {
		//guard !UserDefaults.standard.disableInGameUI else { return nil }
		switch self {
		case .lookingForSurface:
			return NSLocalizedString("Find a flat surface to place the game.", comment: "")
		case .placingBoard:
			return NSLocalizedString("Scale, rotate or move the board.", comment: "")
		case .adjustingBoard:
			return NSLocalizedString("Make adjustments and tap to continue.", comment: "")
		case .gameInProgress:
			//			if UserDefaults.standard.hasOnboarded || UserDefaults.standard.spectator {
			//				return nil
			//			} else {
			//				return NSLocalizedString("Move closer to a slingshot.", comment: "")
			//			}
			return nil
		case .setupLevel:
			return nil
		case .waitingForBoard:
			return NSLocalizedString("Synchronizing world map…", comment: "")
		case .localizingToBoard:
			return NSLocalizedString("Point the camera towards the table.", comment: "")
		case .setup:
			return nil
		}
	}
}
