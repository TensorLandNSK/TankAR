//
//  Projectile.swift
//  TanksAR
//
//  Created by Tensor Guest on 19.04.2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Projectile : SCNNode {
    
    override init() {
        super.init()
        
        self.geometry = SCNCylinder(radius: 0.005, height: 0.01)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        self.geometry?.firstMaterial = material
        
        self.position = SCNVector3(0, 0, 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
