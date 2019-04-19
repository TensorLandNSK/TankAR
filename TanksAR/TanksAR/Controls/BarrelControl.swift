//
//  BarrelControl.swift
//  Controls
//
//  Created by Хакатон on 19/04/2019.
//  Copyright © 2019 Хакатон. All rights reserved.
//

import UIKit

func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
    let dx = p1.x - p2.x
    let dy = p1.y - p2.y
    return sqrt(dx*dx + dy*dy)
    
}

protocol RotateDelegate {
    func rotate(orientation: CGPoint)
}

class BarrelControl: UIView {
    var delegate: RotateDelegate!
    let button: UIView
    let buttonSize: CGFloat = 50.0
    override init(frame: CGRect) {
        button = UIView(frame: CGRect(x: frame.width/2 - buttonSize/2, y: frame.height/2 - buttonSize/2, width: buttonSize, height: buttonSize))
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        button = UIView(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        super.init(coder: aDecoder)
        commonInit()
        button.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
    }
    
    func commonInit() {
        button.backgroundColor = .white
        button.layer.cornerRadius = buttonSize/2
        self.backgroundColor = UIColor(white: 1, alpha: 0.3)
        self.layer.cornerRadius = frame.height / 2
        
        self.addSubview(button)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        button.addGestureRecognizer(pan)
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let localCenter = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        if recognizer.state == .ended {
            button.center = localCenter
        }
        
        let translation = recognizer.translation(in: self)
        
        let newP = CGPoint(x:button.center.x + translation.x,
                y:button.center.y + translation.y)
        
        if distance(p1: localCenter, p2: newP) < buttonSize {
            button.center = newP
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self)
        let orientation = CGPoint(x: button.center.x - localCenter.x, y: -button.center.y + localCenter.y)
        delegate.rotate(orientation: orientation)
    }
    
}
