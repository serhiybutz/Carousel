//
//  GeometryParameters.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import CoreGraphics

struct GeometryParameters {
    // MARK: - Properties

    private let bounds: CGRect
    private let itemSize: CGSize
    private let itemsCount: Int

    private var visCenter: CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }

    private var indices: ClosedRange<Int> {
        0...(itemsCount - 1)
    }

    let wheelParameters: WheelParameters

    // MARK: - Initialization

    init(bounds: CGRect, wheelRadius: CGFloat, itemSize: CGSize, itemsCount: Count, angleStep: CGFloat) {
        
        self.bounds = bounds
        self.itemSize = itemSize
        self.itemsCount = itemsCount.value

        self.wheelParameters = WheelParameters(radius: wheelRadius, angleStep: angleStep)
    }

    // MARK: - API

    func visibleIndices(for angle: CGFloat) -> ClosedRange<Int> {
        wheelParameters.visibleIndicesRange(forOriginAngle: angle)
            .clamped(to: indices)
    }

    func angle(forItemIdx idx: Int) -> CGFloat {
        wheelParameters.angle(forItemAt: idx.clamped(to: indices))
    }

    func xDisplacement(ofItemAt idx: Int, withOriginAngle angle: CGFloat) -> CGFloat {
        wheelParameters.xProjection(ofItemAt: idx, withOriginAngle: angle)
    }

    func offset(ofItemAt idx: Int, withOriginAngle angle: CGFloat) -> CGSize {
        CGSize(
            width: visCenter.x + xDisplacement(ofItemAt: idx, withOriginAngle: angle),
            height: visCenter.y
        )
    }

    func nearestStepIdx(byAngle angle: CGFloat, neighborSelectionRule: WheelParameters.NeighborSelectionRule) -> Int? {
        let idx = wheelParameters
            .stepIdx(byAngle: angle, neighborSelectionRule: neighborSelectionRule)
        if indices ~= idx {
            return idx
        } else {
            return nil
        }
    }

    func activeIdx(byAngle angle: CGFloat) -> Int {
        wheelParameters.stepIdx(byAngle: angle).clamped(to: indices)
    }

    func fullAngleRange(addingExtraAngle extraAngle: CGFloat = 0) -> ClosedRange<CGFloat> {
        0...(wheelParameters.angleStep * CGFloat((itemsCount - 1)) + extraAngle)
    }

    var fullCircleOffsetRange: ClosedRange<CGFloat> {
        0...(wheelParameters.circleOffset(forAngle: fullAngleRange().upperBound))
    }

    func nearestCircleOffsetAnchor(toCircleOffsetProjection projection: CGFloat) -> CGFloat {
        wheelParameters
            .nearestCircleOffsetAnchor(toCircleOffsetProjection: projection)
            .clamped(to: fullCircleOffsetRange)
    }

    func circleOffsetAnchor(forItemAt idx: Int) -> CGFloat {
        wheelParameters
            .circleOffsetAnchor(forItemAt: idx)
            .clamped(to: fullCircleOffsetRange)
    }
}
