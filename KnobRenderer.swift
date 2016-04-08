//
//  KnobRenderer.swift
//  CustomControl
//
//  Created by iwritecode on 4/7/16.
//  Copyright © 2016 sojiwritescode. All rights reserved.
//

import UIKit

class KnobRenderer {
    
    // MARK: - Initializers
    
    init() {
        trackLayer.fillColor = UIColor.clearColor().CGColor
        pointerLayer.fillColor = UIColor.clearColor().CGColor
    }
    
    // MARK: - Properties
    
    // Track Layer
    let trackLayer = CAShapeLayer()
    
    var startAngle: CGFloat = 0.0 {
        didSet { update() }
    }
    
    var endAngle: CGFloat = 0.0 {
        didSet { update() }
    }
    
    // Pointer Layer
    let pointerLayer = CAShapeLayer()
    
    var backingPointerAngle: CGFloat = 0.0
    
    var pointerAngle: CGFloat {
        get { return backingPointerAngle }
        set { setPointerAngle(newValue, animated: false) }
    }
    
    var pointerLength: CGFloat = 0.0 {
        didSet { update() }
    }
    
    var lineWidth: CGFloat = 1.0 {
        didSet { update() }
    }
    
    var strokeColor: UIColor {
        get { return UIColor(CGColor: trackLayer.strokeColor!) }
        set(strokeColor) {
            trackLayer.strokeColor = strokeColor.CGColor
            pointerLayer.strokeColor = strokeColor.CGColor
        }
    }
    
    // MARK: - Methods
    
    func setPointerAngle(pointerAngle: CGFloat, animated: Bool) {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        pointerLayer.transform = CATransform3DMakeRotation(pointerAngle, 0.0, 0.0, 0.1)
        
        if animated {
            let midAngle = (max(pointerAngle, self.pointerAngle) - min(pointerAngle, self.pointerAngle)) / 2.0 + min(pointerAngle, self.pointerAngle)
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.duration = 0.25
            
            animation.values = [self.pointerAngle, midAngle, pointerAngle]
            animation.keyTimes = [0.0, 0.5, 1.0]
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            pointerLayer.addAnimation(animation, forKey: nil)
        }
        
        CATransaction.commit()
        
        self.backingPointerAngle = pointerAngle
    }
    
    func update(bounds: CGRect) {
        let position = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        trackLayer.bounds = bounds
        trackLayer.position = position
        pointerLayer.bounds = bounds
        pointerLayer.position = position
    }
    
    func update() {
        trackLayer.lineWidth = lineWidth
        pointerLayer.lineWidth = lineWidth
        
        updateTrackLayerPath()
        updatePointerLayerPath()
    }
    
    func updateTrackLayerPath() {
        let arcCenter = CGPoint(x: trackLayer.bounds.width / 2.0, y: trackLayer.bounds.height / 2.0)
        let offset = max(pointerLength, trackLayer.lineWidth / 2.0)
        let radius = min(trackLayer.bounds.height, trackLayer.bounds.width) / 2.0 - offset
        trackLayer.path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).CGPath
    }
    
    func updatePointerLayerPath() {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: pointerLayer.bounds.width - pointerLength - pointerLayer.lineWidth / 2.0,
            y: pointerLayer.bounds.height / 2.0))
        path.addLineToPoint(CGPoint(x: pointerLayer.bounds.width, y: pointerLayer.bounds.height / 2.0))
        pointerLayer.path = path.CGPath
    }
    
}


