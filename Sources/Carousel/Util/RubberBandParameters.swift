//
//  RubberBandParameters.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation
import CoreGraphics

struct RubberBandParameters {
    // MARK: - Properties

    let coeff: CGFloat
    let bounds: ClosedRange<CGFloat>
    let displacement: CGFloat

    // MARK: - Initialization

    init(coeff: CGFloat = 0.55, bounds: ClosedRange<CGFloat>, displacement: CGFloat) {
        self.coeff = coeff
        self.displacement = displacement
        self.bounds = bounds
    }

    // MARK: - API

    func clamp(_ point: CGFloat) -> CGFloat {
        rubberBandClamp(point, coeff: coeff, bounds: bounds, displacement: displacement)
    }

    // MARK: - Helpers

    private func rubberBandClamp(_ x: CGFloat, coeff: CGFloat, bounds: ClosedRange<CGFloat>, displacement: CGFloat) -> CGFloat {
        let clampedX = x.clamped(to: bounds)
        let diff = abs(x - clampedX)
        return clampedX + CGFloat(
            signOf: -clampedX,
            magnitudeOf: rubberBandClamp(diff, coeff: coeff, displacement: displacement))
    }

    private func rubberBandClamp(_ value: CGFloat, coeff: CGFloat, displacement: CGFloat) -> CGFloat {
        (1.0 - (1.0 / (value * coeff / displacement + 1.0))) * displacement
    }
}
