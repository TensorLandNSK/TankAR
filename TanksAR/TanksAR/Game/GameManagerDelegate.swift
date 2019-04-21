//
//  GameManagerDelegate.swift
//  TanksAR
//
//  Created by tensor_guest on 20/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import ARKit
import CoreGraphics

protocol GameManagerDelegate {
    func didWorldReceieved(worldMap : ARWorldMap)
    func didTankMovementReceived(vector: CGPoint)
    func didBarrelMovementReceived(vector: CGPoint)
    func didHitReceived()
}
