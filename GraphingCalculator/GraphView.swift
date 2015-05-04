//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by Rob Isenberg on 04/05/2015.
//  Copyright (c) 2015 Rob Isenberg. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
  func yForX(x: CGFloat) -> CGFloat?
  var graphViewDataSourceIsReady: Bool { get }
}

@IBDesignable
class GraphView: UIView {
  
  @IBInspectable
  var pointsPerUnit: CGFloat = 20.0 {
    didSet { setNeedsDisplay() }
  }
  
  weak var datasource: GraphViewDataSource? = nil
  
  override func drawRect(rect: CGRect) {
    let axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
    axesDrawer.drawAxesInRect(bounds, origin: localCenter, pointsPerUnit: pointsPerUnit)
    
    println("bounds: \(bounds)")
    
    if datasource != nil && datasource!.graphViewDataSourceIsReady {
      let pathOfDrawnFunction = UIBezierPath()
      for rawX in 0...Int(ceil(bounds.width)) {
        let newPoint = rawPointForRawXValue(CGFloat(rawX))
        let x = CGFloat(rawX)
        if rawX == 0 {
          pathOfDrawnFunction.moveToPoint(newPoint)
        }
        else {
          pathOfDrawnFunction.addLineToPoint(newPoint)
        }
      }
      pathOfDrawnFunction.stroke()
    }
  }
  
  func scale(gesture: UIPinchGestureRecognizer) {
    if gesture.state == .Changed {
      pointsPerUnit *= gesture.scale
      println("pointsPerUnit: \(pointsPerUnit)")
      gesture.scale = 1 // reset gesture's scale
    }
  }
  
  // PRIVATE
  
  private func rawXToGraphX(x: CGFloat) -> CGFloat { return (x - localCenter.x) / pointsPerUnit }
  private func graphYToRawY(y: CGFloat) -> CGFloat { return localCenter.y - (y * pointsPerUnit) }
  
  private var localCenter: CGPoint { return convertPoint(center, fromView: superview) }

  private func rawPointForRawXValue(x: CGFloat) -> CGPoint {
    let graphY = datasource!.yForX(rawXToGraphX(x))!
    let y = graphYToRawY(graphY)
    return CGPoint(x: x, y: y)
  }
  
}
