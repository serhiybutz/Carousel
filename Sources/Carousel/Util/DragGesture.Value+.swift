//
//  DragGesture.Value+.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import SwiftUI

extension DragGesture.Value {

    var velocity: CGPoint {
        let d = Const.decelerationRate / (1000.0 * (1.0 - Const.decelerationRate))
        return CGPoint (x: (location.x - predictedEndLocation.x) / d,
                        y: (location.y - predictedEndLocation.y) / d)
    }
}
