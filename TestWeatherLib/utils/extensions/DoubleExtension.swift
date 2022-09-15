//
//  DoubleExtension.swift
//  demo
//
//  Created by diegitsen on 14/09/22.
//

import Foundation

extension Double {
  var degreesToRadians: Double { return Double(CGFloat(self).degreesToRadians) }
  var radiansToDegrees: Double { return Double(CGFloat(self).radiansToDegrees) }
}
