//
//  NonCollapsingSplitViewController.swift
//  GraphingCalculator
//
//  Created by Rob Isenberg on 04/05/2015.
//  Copyright (c) 2015 Rob Isenberg. All rights reserved.
//

import UIKit

class NonCollapsingSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
  }

  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
    return true
  }
}
