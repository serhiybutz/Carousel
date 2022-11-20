//
//  CubicBezierCurvesLinkUp.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation

struct CubicBezierCurvesLinkUp {
    // MARK: - Properties

    private let curves: [CubicBezierCurve]

    // MARK: - Initialization

    init?(startCoord: CGPoint, continuations: [(handle1: CGPoint, handle2: CGPoint, nextCoord: CGPoint)]) {
        guard !continuations.isEmpty else { return nil }
        var startCoord = startCoord
        var curves: [CubicBezierCurve] = []
        for continuation in continuations {
            guard let curve = CubicBezierCurve(
                c0: startCoord,
                c1: continuation.handle1,
                c2: continuation.handle2,
                c3: continuation.nextCoord) else { return nil }
            curves.append(curve)
            startCoord = continuation.nextCoord
        }
        self.curves = curves
    }

    // MARK: - API

    func getY(at x: CGFloat) -> CGFloat? {
        for curve in curves {
            if curve.xBounds ~= x {
                return curve.getY(at: x)
            }
        }
        return nil
    }

    // MARK: - Types

    struct CubicBezierCurve {
        // MARK: - Properties

        private let c0, c1, c2, c3: CGPoint
        
        // MARK: - Initialization

        init?(c0: CGPoint, c1: CGPoint, c2: CGPoint, c3: CGPoint) {
            guard c0.x < c3.x else { return nil }
            self.c0 = c0
            self.c1 = c1
            self.c2 = c2
            self.c3 = c3
        }

        // MARK: - API

        func getY(at x: CGFloat) -> CGFloat? {
            guard xBounds ~= x else { return nil }
            var tL = T(0)!, tR = T(1)!
            var t: T!
            while true {
                let tM = T((tL.value + tR.value) / 2)!
                let xM = computeValue(at: tM, coord: \.x)
                let distance = xM - x
                if distance.magnitude < Const.CubicBezierCurve.tolerance {
                    t = tM
                    break
                }
                if distance < 0 {
                    tL = tM
                } else {
                    tR = tM
                }
            }
            return computeValue(at: t, coord: \.y)
        }

        var xBounds: ClosedRange<CGFloat> {
            c0.x...c3.x
        }

        // MARK: - Helpers

        private func computeValue(at t: T, coord: KeyPath<CGPoint, CGFloat>) -> CGFloat {
            let t = t.value
            return (((-c0[keyPath: coord] + 3 * c1[keyPath: coord] - 3 * c2[keyPath: coord] + c3[keyPath: coord]) * t + (3 * c0[keyPath: coord] - 6 * c1[keyPath: coord] + 3 * c2[keyPath: coord])) * t + (-3 * c0[keyPath: coord] + 3 * c1[keyPath: coord])) * t + c0[keyPath: coord]
        }

        // MARK: - Types

        private struct T: Equatable {
            let value: CGFloat
            init?(_ value: CGFloat) {
                guard 0...1 ~= value else { return nil }
                self.value = value
            }
        }
    }
}
