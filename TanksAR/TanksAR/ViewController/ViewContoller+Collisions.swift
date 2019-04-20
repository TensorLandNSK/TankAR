//
//  ViewContoller+Collisions.swift
//  TanksAR
//
//  Created by Хакатон on 20/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

extension ViewController : SCNPhysicsContactDelegate {
    enum colliderCategory: Int {
        case tank = 1
        case projectile
        case ground
    }    
}
