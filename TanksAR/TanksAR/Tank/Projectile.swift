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
    var boardSize = CGSize(width: 0.3, height: 0.54)
    var scaleFactor: Float?
    
    override init() {
        super.init()
        
        self.geometry = SCNCylinder(radius: 0.0001, height: 0.05)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        self.geometry?.firstMaterial = material
        
        self.position = SCNVector3(0, 0, 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rescale(size: CGSize) {
        let minSize: SCNVector3 = self.boundingBox.min
        let maxSize: SCNVector3 = self.boundingBox.max
        scaleFactor = Float(0.5) * Float(boardSize.width) / abs(maxSize.x - minSize.x)
        
        self.scale = SCNVector3( scaleFactor!, scaleFactor!, scaleFactor! )
    }
}
