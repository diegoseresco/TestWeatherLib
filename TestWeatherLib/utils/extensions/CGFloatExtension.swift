//
//  CGFloatExtension.swift
//  demo
//
//  Created by diegitsen on 14/09/22.
//

import Foundation

extension CGFloat {
  var degreesToRadians: CGFloat { return self * .pi / 180 }
  var radiansToDegrees: CGFloat { return self * 180 / .pi }
}
