//
//  WheelMomentum.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import OSLog
import SwiftUI
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

protocol WheelMomentumDelegate: AnyObject {
    var circleOffset: CGFloat { get set }
    var circleOffsetBounds: ClosedRange<CGFloat> { get }
    func nearestAnchor(to projection: CGFloat) -> CGFloat
    func anchor(by idx: Int) -> CGFloat
}

final class WheelMomentum {
    // MARK: - Properties

    private let delegate: WheelMomentumDelegate

    private var circleOffset: CGFloat {
        get {
            delegate.circleOffset
        }
        set {
            delegate.circleOffset = newValue
        }
    }

    private let onComplete: (() -> Void)

    private enum Animation {
        case bounce(TimerAnimation)
        case spring(TimerAnimation)
        var current: TimerAnimation {
            switch self {
            case .bounce(let timerAnimation):
                return timerAnimation
            case .spring(let timerAnimation):
                return timerAnimation
            }
        }
    }
    private var animation: Animation?

    // MARK: - Initialization

    init(initialVelocity: CGFloat, delegate: WheelMomentumDelegate, onComplete: @escaping () -> Void)  {

        self.delegate = delegate
        self.onComplete = onComplete

        completeGesture(withVelocity: initialVelocity)
    }

    init(landPos: CGFloat, delegate: WheelMomentumDelegate, onComplete: @escaping () -> Void)  {

        self.delegate = delegate
        self.onComplete = onComplete

        land(atProjection: landPos, with: 0)
    }

    init(atItemIdx idx: Int, delegate: WheelMomentumDelegate, onComplete: @escaping () -> Void)  {

        self.delegate = delegate
        self.onComplete = onComplete

        land(atItemIdx: idx, with: 0)
    }

    deinit {
        animation = nil
    }

    // MARK: - Helpers

    private func completeGesture(withVelocity velocity: CGFloat) {
        
        if delegate.circleOffsetBounds ~= circleOffset {
            completeGesture(velocity: velocity)
        } else {
            bounce(withVelocity: velocity)
        }
    }

    private func bounce(withVelocity velocity: CGFloat) {

        let restOffset = circleOffset.clamped(to: delegate.circleOffsetBounds)
        let displacement = circleOffset - restOffset

        let parameters = SpringTimingParameters(spring: Spring.default,
                                                displacement: displacement,
                                                initialVelocity: velocity,
                                                threshold: Const.threshold)

        let timerAnimation = TimerAnimation(
            duration: parameters.duration,
            animations: { [weak self] _, time in
                self?.circleOffset = restOffset + parameters.value(at: time)
            }, completion: { [weak self] _ in
                self?.onComplete()
            })
        self.animation = .bounce(timerAnimation)
    }

    private func completeGesture(velocity: CGFloat) {

        let projection = project(value: circleOffset,
                                 velocity: velocity,
                                 decelerationRate: Const.decelerationRate)
        land(atProjection: projection, with: velocity)
    }

    private func land(atItemIdx idx: Int, with velocity: CGFloat) {

        let anchor = delegate.anchor(by: idx)
        land(atAnchor: anchor, with: velocity)
    }

    private func land(atProjection projection: CGFloat, with velocity: CGFloat) {

        let anchor = delegate.nearestAnchor(to: projection)
        land(atAnchor: anchor, with: velocity)
    }

    private func land(atAnchor anchor: CGFloat, with velocity: CGFloat) {

        let timingParameters = SpringTimingParameters(
            spring: Spring.default,
            displacement: circleOffset - anchor,
            initialVelocity: velocity,
            threshold: Const.threshold)

        let timerAnimation = TimerAnimation(
            duration: timingParameters.duration,
            animations: { [weak self] _, time in
                self?.circleOffset = anchor + timingParameters.value(at: time)
            }, completion: { [weak self] _ in
                self?.onComplete()
            })
        self.animation = .spring(timerAnimation)
    }

    private func project(value: CGFloat, velocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
        value - velocity / (1000.0 * log(decelerationRate))
    }
}
