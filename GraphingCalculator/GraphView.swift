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
  var pointsPerUnit: CGFloat = 20.0 { didSet { setNeedsDisplay() } }
  
  weak var datasource: GraphViewDataSource? = nil
  
  override func drawRect(rect: CGRect) {
    let axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
    axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: pointsPerUnit)
    
    if datasource != nil && datasource!.graphViewDataSourceIsReady {
      let chartLinePath = UIBezierPath()
      for x in 0...Int(ceil(bounds.width)) {
        let x = CGFloat(x)
        let newPoint = calculatePointForX(x)

        if x == 0 { chartLinePath.moveToPoint(newPoint) }
        else { chartLinePath.addLineToPoint(newPoint) }
      }
      chartLinePath.stroke()
    }
  }
  
  func scale(gesture: UIPinchGestureRecognizer) {
    if gesture.state == .Changed {
      pointsPerUnit *= gesture.scale
      gesture.scale = 1 // reset gesture's scale
    }
  }
  
  func pan(recognizer: UIPanGestureRecognizer) {
    switch(recognizer.state) {
    case .Ended: fallthrough
    case .Changed:
      let translation = recognizer.translationInView(self)
      origin.x += translation.x
      origin.y += translation.y
      recognizer.setTranslation(CGPointZero, inView: self)
      setNeedsDisplay()
    default: break
    }
  }
  
  // PRIVATE
  
  private func toGraphX(x: CGFloat) -> CGFloat { return (x - origin.x) / pointsPerUnit }
  private func fromGraphY(y: CGFloat) -> CGFloat { return origin.y - (y * pointsPerUnit) }
  
  private lazy var origin: CGPoint = {
    return self.convertPoint(self.center, fromView: self.superview)
  }()

  private func calculatePointForX(x: CGFloat) -> CGPoint {
    let graphY = datasource!.yForX(toGraphX(x))!
    let y = fromGraphY(graphY)
    return CGPoint(x: x, y: y)
  }
  
}
