//
//  WheelParameters.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation

struct WheelParameters {

    // MARK: - Properties

    let radius: CGFloat
    
    /// Angle distance between anchors.
    let angleStep: CGFloat

    let pi_2: CGFloat = .pi / 2

    // MARK: - Initialization

    init(radius: CGFloat, angleStep: CGFloat) {
        self.radius = radius
        self.angleStep = angleStep
    }

    // MARK: - API

    func xProjection(ofItemAt idx: Int, withOriginAngle originAngle: CGFloat) -> CGFloat {
        let angle = angleStep * CGFloat(idx) - originAngle
        return sin(angle) * radius
    }

    func yProjection(ofItemAt idx: Int, withOriginAngle originAngle: CGFloat) -> CGFloat {
        let angle = angleStep * CGFloat(idx) - originAngle
        return cos(angle) * radius
    }

    func visibleIndicesRange(forOriginAngle originAngle: CGFloat) -> ClosedRange<Int> {
        let lower = Int(((originAngle - pi_2) / angleStep).rounded())
        let upper = Int(((originAngle + pi_2) / angleStep).rounded())
        return lower...upper
    }

    func angle(forItemAt idx: Int) -> CGFloat {
        angleStep * CGFloat(idx)
    }

    func angle(forCircleOffset circleOffset: CGFloat) -> CGFloat {
        circleOffset / radius
    }

    func circleOffset(forAngle angle: CGFloat) -> CGFloat {
        angle * radius
    }

    func stepIdx(byAngle angle: CGFloat, neighborSelectionRule: NeighborSelectionRule = .nearest) -> Int {
        let stepIdxFloat = angle / angleStep
        switch neighborSelectionRule {
        case .nearest:
            return Int(stepIdxFloat.rounded())
        case .left:
            return Int(stepIdxFloat.rounded(.down))
        case .right:
            return Int(stepIdxFloat.rounded(.up))
        }
    }

    func nearestAngleAnchor(toAngleProjection angleProjection: CGFloat, neighborSelectionRule: NeighborSelectionRule = .nearest) -> CGFloat {
        CGFloat(stepIdx(byAngle: angleProjection, neighborSelectionRule: neighborSelectionRule)) * angleStep
    }

    func nearestCircleOffsetAnchor(toCircleOffsetProjection projection: CGFloat, neighborSelectionRule: NeighborSelectionRule = .nearest) -> CGFloat {
        let angle = angle(forCircleOffset: projection)
        let anchorAngle = nearestAngleAnchor(toAngleProjection: angle, neighborSelectionRule: neighborSelectionRule)
        return circleOffset(forAngle: anchorAngle)
    }

    func angle(forProjection projection: CGFloat) -> CGFloat? {
        guard projection.magnitude <= radius else { return nil }
        return asin(projection / radius)
    }

    func circleOffset(forProjection projection: CGFloat) -> CGFloat? {
        guard let angle = angle(forProjection: projection) else { return nil }
        return circleOffset(forAngle: angle)
    }

    func circleOffsetAnchor(forItemAt idx: Int) -> CGFloat {
        circleOffset(forAngle: angle(forItemAt: idx))
    }

    // MARK: - Types
    
    enum NeighborSelectionRule {
        case nearest, left, right
    }
}
