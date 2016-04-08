//
//  Knob.swift
//  CustomControl
//
//  Created by iwritecode on 4/7/16.
//  Copyright © 2016 sojiwritescode. All rights reserved.
//

import UIKit

class Knob: UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createSublayers()
        
        // Add  gesture recognizer.
        let gr = RotationGestureRecognizer(target: self, action: #selector(Knob.handleRotation(_:)))
        self.addGestureRecognizer(gr)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tintColorDidChange() {
        knobRenderer.strokeColor = tintColor
    }
    
    // MARK: - Properties
    
    private let knobRenderer = KnobRenderer()
    
    /** Contains a boolean value that states whether the control generates continuous updates as the value is changed. */
    var continuous = true
    
    // Knob's stored value for comparison
    var backingValue: Float = 0.0
    
    /** Contains the knob's minimum value. */
    var minimumValue: Float = 0.0
    
    /** Contains the knob's maximum value. */
    var maximumValue: Float = 1.0
    
    /** Contains the control's current value. */
    var value: Float {
        get { return backingValue }
        set { setValue(newValue, animated: false) }
    }
    
    /** Specifies the starting angle of the knob's track. Defaults to -11π/8 */
    var startAngle: CGFloat {
        get { return knobRenderer.startAngle }
        set { knobRenderer.startAngle = newValue }
    }
    
    /** Specifies the ending angle of the knob's track. Defaults to 3π/8 */
    var endAngle: CGFloat {
        get { return knobRenderer.endAngle }
        set { knobRenderer.endAngle = newValue }
    }
    
    /** Specifies the width, in points, of the knob control track (and pointer). Defaults to 2.0 */
    var lineWidth: CGFloat {
        get { return knobRenderer.lineWidth }
        set { knobRenderer.lineWidth = newValue }
    }
    
    /** Specifies the length, in points, of the knob control's pointer. Defaults to 6.0 */
    var pointerLength: CGFloat {
        get { return knobRenderer.pointerLength }
        set { knobRenderer.pointerLength = newValue }
    }
    
    // MARK: - Methods
    
    /** Sets the receiver's current value. */
    func setValue(value: Float, animated: Bool) {
        //        if value != backingValue {
        //            backingValue = min(maximumValue, max(minimumValue, value))
        //        }
        
        if value != self.value {
            // Save the value to backingValue
            // Limit it to the requested bounds
            self.backingValue = min(maximumValue, max(minimumValue, value))
            
            // Change the angle
            let angleRange = endAngle - startAngle
            let valueRange = CGFloat(maximumValue - minimumValue)
            let angle = CGFloat(value - minimumValue) / valueRange * angleRange + startAngle
            knobRenderer.setPointerAngle(angle, animated: animated)
        }
    }
    
    // Setting default property values.
    func createSublayers() {
        knobRenderer.update(bounds)
        knobRenderer.strokeColor = tintColor
        knobRenderer.startAngle = -CGFloat(M_PI * 11.0 / 8.0)
        knobRenderer.endAngle = CGFloat(M_PI * 3.0 / 8.0)
        knobRenderer.pointerAngle = knobRenderer.startAngle
        knobRenderer.lineWidth = 2.0
        knobRenderer.pointerLength = 6.0
        
        layer.addSublayer(knobRenderer.trackLayer)
        layer.addSublayer(knobRenderer.pointerLayer)
    }
    
    
    func handleRotation(sender: AnyObject) {
        let gr = sender as! RotationGestureRecognizer
        
        // 1. Calculate the mid-point angle
        let midPointAngle = (2.0 * CGFloat(M_PI) + self.startAngle - self.endAngle) / 2.0 + self.endAngle
        
        // 2. Ensure the angle is within a suitable range
        var boundedAngle = gr.rotation
        if boundedAngle > midPointAngle {
            boundedAngle -= 2.0 * CGFloat(M_PI)
        } else if boundedAngle < (midPointAngle - 2.0 * CGFloat(M_PI)) {
            boundedAngle += 2 * CGFloat(M_PI)
        }
        
        // 3. Bound the angle to the within the suitable range
        boundedAngle = min(self.endAngle, max(self.startAngle, boundedAngle))
        
        // 4. Conver the angle to a value
        let angleRange = endAngle - startAngle
        let valueRange = maximumValue - minimumValue
        let valueForAngle = Float(boundedAngle - startAngle) / Float(angleRange) * valueRange + minimumValue
        
        // 5. Set the control to this value
        self.value = valueForAngle
        
        // Notify of value change
        if continuous {
            sendActionsForControlEvents(.ValueChanged)
        } else {
            // Only send an update if the gesture has completed
            if (gr.state == UIGestureRecognizerState.Ended) || (gr.state == UIGestureRecognizerState.Cancelled) {
                sendActionsForControlEvents(.ValueChanged)
            }
        }
    }
}

import UIKit.UIGestureRecognizerSubclass

private class RotationGestureRecognizer: UIPanGestureRecognizer {
    
    override init(target: AnyObject?, action: Selector) {
        super.init(target: target, action: action)
        
        minimumNumberOfTouches = 1
        maximumNumberOfTouches = 1
    }
    
    var rotation: CGFloat = 0.0
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        updateRotationWithTouches(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        updateRotationWithTouches(touches)
    }
    
    func updateRotationWithTouches(touches: Set<NSObject>) {
        if let touch = touches[touches.startIndex] as? UITouch {
            self.rotation = rotationForLocation(touch.locationInView(self.view))
        }
    }
    
    func rotationForLocation(location: CGPoint) -> CGFloat {
        let offset = CGPoint(x: location.x - view!.bounds.midX, y: location.y - view!.bounds.midY)
        return atan2(offset.y, offset.x)
    }
    
}
