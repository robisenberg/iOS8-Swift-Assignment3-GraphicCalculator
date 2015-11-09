//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by Rob Isenberg on 04/05/2015.
//  Copyright (c) 2015 Rob Isenberg. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
  func yForX(x: Double) -> Double?
}

@IBDesignable
class GraphView: UIView {
  
  @IBInspectable
  var pointsPerUnit: CGFloat = 20.0 { didSet { setNeedsDisplay() } }
  
  weak var datasource: GraphViewDataSource? = nil
  
  override func drawRect(rect: CGRect) {
    let axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
    axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: pointsPerUnit)
    
    if datasource != nil {
      let chartLinePath = UIBezierPath()
      var previousPointWasUndrawable = true
      
      for viewCoordX in 0...Int(ceil(bounds.width)) {
        let viewCoordX = CGFloat(viewCoordX)
        let x = toGraphX(viewCoordX)
        let y = datasource!.yForX(Double(x))

        if y == nil || (!y!.isNormal && !y!.isZero) {
          previousPointWasUndrawable = true
          continue
        }
        
        let viewCoordY = fromGraphY(CGFloat(y!))
        let point = CGPoint(x: viewCoordX, y: viewCoordY)

        if previousPointWasUndrawable {
          chartLinePath.moveToPoint(point)
          previousPointWasUndrawable = false
        }
        else {
          chartLinePath.addLineToPoint(point)
        }
      }
      chartLinePath.stroke()
    }
  }
  
  // MARK: - Gestures
  
  func scale(gesture: UIPinchGestureRecognizer) {
    if gesture.state == .Changed {
      pointsPerUnit *= gesture.scale
      gesture.scale = 1 // reset gesture's scale
      setNeedsDisplay()
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
  
  func tapped(recognizer: UITapGestureRecognizer) {
    switch(recognizer.state) {
    case .Ended:
      origin = recognizer.locationInView(self)
      setNeedsDisplay()
    default: break;
    }
  }
  
  // MARK: - Private Implementation
  
  private func toGraphX(x: CGFloat) -> CGFloat { return (x - origin.x) / pointsPerUnit }
  private func fromGraphY(y: CGFloat) -> CGFloat { return origin.y - (y * pointsPerUnit) }
  private lazy var origin: CGPoint = {
    return self.convertPoint(self.center, fromView: self.superview)
  }()
}
