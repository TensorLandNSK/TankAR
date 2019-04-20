//
//  FireControl.swift
//  Controls
//
//  Created by Хакатон on 19/04/2019.
//  Copyright © 2019 Хакатон. All rights reserved.
//

import UIKit

protocol FireDelegate {
    func fire()
}

class FireControl: UIButton {
    var lastTime: Date = Date() - 5.0
    let dT = 5.0
    var delegateFire: FireDelegate!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .red
        self.layer.cornerRadius = frame.height/2
        
        self.addTarget(self, action: #selector(touchDown), for: UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(touchUp), for: UIControl.Event.touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .red
        self.layer.cornerRadius = frame.height/2
        
        self.addTarget(self, action: #selector(touchDown), for: UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(touchUp), for: UIControl.Event.touchUpInside)
        
        
        //fatalError("init(coder:) has not been implemented")
    }
    
    @objc func touchDown() {
        self.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        if (lastTime.timeIntervalSinceNow) < -dT {
            delegateFire.fire()
            lastTime = Date()
        }
    }
    @objc func touchUp() {
        self.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    }
}
