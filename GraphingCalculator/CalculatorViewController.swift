//
//  ViewController.swift
//  Calculator
//
//  Created by Rob Isenberg on 28/01/2015.
//  Copyright (c) 2015 Rob Isenberg. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
  
  var userIsInTheMiddleOfEnteringDigits = false
  var brain = CalculatorBrain()
  
  var displayValue: Double? {
    get { return NSNumberFormatter().numberFromString(display.text!)?.doubleValue }
    set {
      userIsInTheMiddleOfEnteringDigits = false
      display.text = newValue?.description ?? " "
      descriptionText.text = "\(brain.description) ="
    }
  }
  
  @IBOutlet weak var descriptionText: UILabel!
  @IBOutlet weak var display: UILabel!
  
  @IBAction func appendDigit(sender: UIButton) {
    let digit = sender.currentTitle!
    
    if userIsInTheMiddleOfEnteringDigits {
      if digit == "." && display.text!.rangeOfString(".") != nil { return }
      display.text = display.text! + digit
    }
    else {
      display.text = digit
      userIsInTheMiddleOfEnteringDigits = true
    }
  }
  
  @IBAction func enterConstant(sender: UIButton) {
    let constant = sender.currentTitle!
    if userIsInTheMiddleOfEnteringDigits { enter() }
    
    if let result = brain.pushConstant(constant) {
      displayValue = result
    }
  }
  
  @IBAction func enter() {
    userIsInTheMiddleOfEnteringDigits = false
    if let value = displayValue { displayValue = brain.pushOperand(value) }
  }
  
  @IBAction func setMemoryValue(sender: UIButton) {
    if let value = displayValue { brain.variableValues["M"] = value }
    displayValue = brain.evaluate()
  }
  
  @IBAction func enterMemoryValue(sender: UIButton) {
    if userIsInTheMiddleOfEnteringDigits { enter() }
    else { displayValue = nil }
    if let value = brain.pushOperand("M") {
      displayValue = value
    }
  }
  
  @IBAction func operatorPressed(sender: UIButton) {
    let operation = sender.currentTitle!
    if userIsInTheMiddleOfEnteringDigits { enter() }
    displayValue = brain.performOperation(operation)
  }

  @IBAction func reset() {
    userIsInTheMiddleOfEnteringDigits = false
    brain.clearAll()
    displayValue = nil
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var destination = segue.destinationViewController as? UIViewController
    if let navigationViewController = destination as? UINavigationController {
      destination = navigationViewController.visibleViewController
    }
    
    if let graphViewController = destination as? GraphViewController {
      let currentCalculatorWithSavedState = CalculatorBrain()
      currentCalculatorWithSavedState.program = brain.program
            
      graphViewController.yForXFunction = { (x: Double) -> Double? in
        currentCalculatorWithSavedState.variableValues["M"] = x
        return currentCalculatorWithSavedState.evaluate()
      }
    }
  }

  // PRIVATE
  
  
  
}

