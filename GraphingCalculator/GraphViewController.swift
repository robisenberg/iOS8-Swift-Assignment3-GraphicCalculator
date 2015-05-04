//
//  GraphViewController.swift
//  GraphingCalculator
//
//  Created by Rob Isenberg on 04/05/2015.
//  Copyright (c) 2015 Rob Isenberg. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {

  func yForX(x: CGFloat) -> CGFloat? {
    if let yFunc = yCalculatingFunction { return yFunc(x) }

    return nil
  }
  
  var graphViewDataSourceIsReady: Bool { return yCalculatingFunction != nil }

  var yCalculatingFunction: (CGFloat -> CGFloat?)? = nil
  
  @IBOutlet weak var graphView: GraphView! {
    didSet {
      self.graphView.datasource = self
      graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
      graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "pan:"))
    }
  }
}
