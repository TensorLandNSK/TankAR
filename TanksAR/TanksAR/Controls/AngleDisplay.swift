//
//  AngleDisplay.swift
//  Controls
//
//  Created by Хакатон on 20/04/2019.
//  Copyright © 2019 Хакатон. All rights reserved.
//

import UIKit

class AngleDisplay: UIView {
    
    var angle: CGFloat = .pi/4 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1, alpha: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        
        //
        let width: CGFloat = 4
        
        
        context!.setFillColor(UIColor.red.cgColor)
        
        context?.translateBy(x: width, y: frame.height - width*1.5)
        context?.rotate(by: -angle)
        let arrow = CGRect(x: -width/2, y: 0, width: frame.width - width/2, height: width)
        context?.addRect(arrow)
        context!.fill(arrow)
        
        context?.rotate(by: angle)
        context?.translateBy(x: -width, y: -frame.height + width*1.5)
        context!.setFillColor(UIColor.yellow.cgColor)
        let vertRect = CGRect(x: 0, y: 0, width: width, height: frame.height)
        let horizRect = CGRect(x: 0, y: frame.height - width, width: frame.width, height: width)
        context?.addRect(vertRect)
        context?.addRect(horizRect)
        context!.fill(horizRect)
        context!.fill(vertRect)
        
        context!.saveGState()
    }
}
