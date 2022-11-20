//
//  Const.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import AppKit

enum DecelerationRate: CGFloat {
    case normal = 0.998
    case fast = 0.99
}

enum Const {
    static let decelerationRate: CGFloat = DecelerationRate.normal.rawValue
    static let threshold = 0.5 / (NSScreen.main?.backingScaleFactor)!

    enum Behavior {
        enum TouchWhileMovingBehavior {
            case jumpToClickLocation
            case jumpToCurrentCenterPosition
        }
        static let touchWhileMovingBehavior: TouchWhileMovingBehavior = .jumpToClickLocation
        static let rubberBandDisplacementAngle: CGFloat = .pi
    }

    enum View {
        static let zoomFactor: CGFloat = 0.3
    }

    enum Spring {
        static let mass: CGFloat = 1
        static let stiffness: CGFloat = 200
        static let dampingRatio: CGFloat = 0.8
    }

    enum CubicBezierCurve {
        static let tolerance: CGFloat = 0.0001
    }

    enum CrossFade {
        static let rangeRatio: CGFloat = 0.15
        static let opacityCorrection: CGFloat = 0.75
    }
}
