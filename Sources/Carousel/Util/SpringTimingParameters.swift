//
//  SpringTimingParameters.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation
import CoreGraphics

struct Spring {
    // MARK: - Properties

    let mass: CGFloat
    let stiffness: CGFloat
    let dampingRatio: CGFloat

    // MARK: - Initialization

    init(mass: CGFloat, stiffness: CGFloat, dampingRatio: CGFloat) {

        self.mass = mass
        self.stiffness = stiffness
        self.dampingRatio = dampingRatio
    }
}

extension Spring {

    static var `default`: Spring {
        Spring(mass: Const.Spring.mass, stiffness: Const.Spring.stiffness, dampingRatio: Const.Spring.dampingRatio)
    }
}

extension Spring {

    var damping: CGFloat {
        2 * dampingRatio * sqrt(mass * stiffness)
    }

    var beta: CGFloat {
        damping / (2 * mass)
    }

    var dampedNaturalFrequency: CGFloat {
        sqrt(stiffness / mass) * sqrt(1 - dampingRatio * dampingRatio)
    }
}

struct SpringTimingParameters {
    // MARK: - Properties

    let spring: Spring
    let displacement: CGFloat
    let initialVelocity: CGFloat
    let threshold: CGFloat

    private let strategy: SpringTimingParametersProtocol

    // MARK: - Initialization

    init(spring: Spring, displacement: CGFloat, initialVelocity: CGFloat, threshold: CGFloat) {

        self.spring = spring
        self.displacement = displacement
        self.initialVelocity = initialVelocity
        self.threshold = threshold

        if 0.nextUp..<1 ~= spring.dampingRatio {
            strategy = UnderdampedSpringTimingParameters(spring: spring,
                                                         displacement: displacement,
                                                         initialVelocity: initialVelocity,
                                                         threshold: threshold)
        } else if spring.dampingRatio == 1 {
            strategy = CriticallyDampedSpringTimingParameters(spring: spring,
                                                              displacement: displacement,
                                                              initialVelocity: initialVelocity,
                                                              threshold: threshold)
        } else {
            preconditionFailure("Boundary violation [0 > dampingRatio <= 1]")
        }
    }
}

extension SpringTimingParameters: SpringTimingParametersProtocol {
    // MARK: - API

    var duration: TimeInterval {
        strategy.duration
    }

    func value(at time: TimeInterval) -> CGFloat {
        strategy.value(at: time)
    }
}

// MARK: - Helpers

private extension SpringTimingParameters {

    struct UnderdampedSpringTimingParameters {
        let spring: Spring
        let displacement: CGFloat
        let initialVelocity: CGFloat
        let threshold: CGFloat
    }
}

extension SpringTimingParameters.UnderdampedSpringTimingParameters: SpringTimingParametersProtocol {
    // MARK: - SpringTimingParametersProtocol

    var duration: TimeInterval {

        guard !(displacement.magnitude == 0 && initialVelocity.magnitude == 0) else {
            return 0
        }

        return TimeInterval(log((c1.magnitude + c2.magnitude) / threshold) / spring.beta)
    }

    func value(at time: TimeInterval) -> CGFloat {
        let t = CGFloat(time)
        let wd = spring.dampedNaturalFrequency
        return exp(-spring.beta * t) * (c1 * cos(wd * t) + c2 * sin(wd * t))
    }

    // MARK: - Helpers

    private var c1: CGFloat {
        displacement
    }

    private var c2: CGFloat {
        (initialVelocity + spring.beta * displacement) / spring.dampedNaturalFrequency
    }
}

private extension SpringTimingParameters {

    struct CriticallyDampedSpringTimingParameters {
        let spring: Spring
        let displacement: CGFloat
        let initialVelocity: CGFloat
        let threshold: CGFloat
    }
}

extension SpringTimingParameters.CriticallyDampedSpringTimingParameters: SpringTimingParametersProtocol {
    // MARK: - SpringTimingParametersProtocol

    var duration: TimeInterval {

        guard !(displacement.magnitude == 0 && initialVelocity.magnitude == 0) else {
            return 0
        }

        let b = spring.beta
        let e = CGFloat(M_E)

        let t1 = 1 / b * log(2 * c1.magnitude / threshold)
        let t2 = 2 / b * log(4 * c2.magnitude / (e * b * threshold))

        return TimeInterval(max(t1, t2))
    }

    func value(at time: TimeInterval) -> CGFloat {
        let t = CGFloat(time)
        return exp(-spring.beta * t) * (c1 + c2 * t)
    }

    // MARK: - Helpers

    private var c1: CGFloat {
        displacement
    }

    private var c2: CGFloat {
        initialVelocity + spring.beta * displacement
    }
}
