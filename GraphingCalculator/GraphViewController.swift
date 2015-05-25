//
//  GraphViewController.swift
//  GraphingCalculator
//
//  Created by Rob Isenberg on 04/05/2015.
//  Copyright (c) 2015 Rob Isenberg. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
  
  var yForXFunction: (Double) -> Double? = { (x: Double) -> Double? in return nil }
  
  func yForX(x: Double) -> Double? {
    return yForXFunction(x)
  }
  
  @IBOutlet weak var graphView: GraphView! {
    didSet {
      self.graphView.datasource = self
      graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
      graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "pan:"))
      
      let tapGesture = UITapGestureRecognizer(target: graphView, action: "tapped:")
      tapGesture.numberOfTapsRequired = 2
      tapGesture.numberOfTouchesRequired = 1
      graphView.addGestureRecognizer(tapGesture)
    }
  }
  
}
