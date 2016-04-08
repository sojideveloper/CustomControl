//
//  ViewController.swift
//  CustomControl
//
//  Created by iwritecode on 4/7/16.
//  Copyright © 2016 sojiwritescode. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var knobPlaceHolder: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var animateSwitch: UISwitch!
    
    var knob: Knob!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        knob = Knob(frame: knobPlaceHolder.bounds)
        knobPlaceHolder.addSubview(knob)
        knob.lineWidth = 4.0
        knob.pointerLength = 12.0
        knob.addTarget(self, action: #selector(ViewController.knobValueChanged(_:)), forControlEvents: .ValueChanged)
    }
    
    @IBAction func sliderValueChanged(slider: UISlider) {
        knob.value = slider.value
        updateLabel()
    }
    
    @IBAction func randomButtonTouched(button: UIButton) {
        let randomValue = Float(arc4random_uniform(101)) / 100.0
        knob.setValue(randomValue, animated: animateSwitch.on)
        valueSlider.setValue(randomValue, animated: animateSwitch.on)
        updateLabel()
    }
    
    func updateLabel() {
        valueLabel.text = NSNumberFormatter.localizedStringFromNumber(knob.value, numberStyle: .DecimalStyle)
    }
    
    func knobValueChanged(knob: Knob) {
        valueSlider.value = knob.value
        
        updateLabel()
    }
    
}
