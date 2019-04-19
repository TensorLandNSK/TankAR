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
	
}
