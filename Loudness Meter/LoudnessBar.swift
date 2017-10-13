//
//  LoudnessBar.swift
//  DragTimer
//
//  Created by Philipp Matthes on 12.Oct.2017
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import GLKit

class LoudnessBar: UIView {
    
    var line: CAShapeLayer!
    var currentValue = 0.0 as CGFloat
    var percentage = 0.0 as CGFloat
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawBar(with frame: CGRect, on view: UIView) {
        line = CAShapeLayer()
        let linePath = UIBezierPath()
        let startPoint = CGPoint(x: frame.width/2, y: frame.height)
        let endPoint = CGPoint(x: frame.width/2, y: 0)
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.white.cgColor
        line.lineWidth = 20
        line.lineCap = kCALineCapRound
        line.lineJoin = kCALineJoinRound
        line.strokeEnd = 0.0
        view.layer.addSublayer(line)
    }
    
    func animateBar(duration: TimeInterval, currentValue: CGFloat, maxValue: CGFloat) {
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        strokeAnimation.duration = duration
        
        strokeAnimation.fromValue = percentage
        percentage = currentValue/maxValue
        strokeAnimation.toValue = percentage
        
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

        line.strokeEnd = percentage

        line.add(strokeAnimation, forKey: "strokeEndAnimation")
    }
    

}
