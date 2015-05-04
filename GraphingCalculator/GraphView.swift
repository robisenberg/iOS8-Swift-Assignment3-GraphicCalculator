//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by Rob Isenberg on 04/05/2015.
//  Copyright (c) 2015 Rob Isenberg. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

  @IBInspectable
  var pointsPerUnit: CGFloat = 20.0
  
  func yForX(x: CGFloat) -> CGFloat? { return 2 * x } // needs to be supplied by delegate

  
  override func drawRect(rect: CGRect) {
    let axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
    axesDrawer.drawAxesInRect(bounds, origin: localCenter, pointsPerUnit: pointsPerUnit)
    
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
  
  
  // PRIVATE
  
  private func rawXToGraphX(x: CGFloat) -> CGFloat { return (x - localCenter.x) / pointsPerUnit }
  private func graphYToRawY(y: CGFloat) -> CGFloat { return localCenter.y - (y * pointsPerUnit) }
  
  private var localCenter: CGPoint { return convertPoint(center, fromView: superview) }

  private func rawPointForRawXValue(x: CGFloat) -> CGPoint {
    let graphY = yForX(rawXToGraphX(x))!
    let y = graphYToRawY(graphY)
    return CGPoint(x: x, y: y)
  }
  
}
