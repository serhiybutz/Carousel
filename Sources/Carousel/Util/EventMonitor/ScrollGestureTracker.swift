//
//  ScrollGestureTracker.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import AppKit

protocol ScrollGestureTrackerDelegate: AnyObject {
    func scrollGestureChanged(_ location: CGPoint, _ translation: CGSize, _ velocity: CGSize)
    func scrollGestureEnded(_ location: CGPoint, _ translation: CGSize, _ velocity: CGSize)
}

final class ScrollGestureTracker: EventMonitorReceiver {

    // MARK: - Properties

    private let coarseMoveFactor: CGFloat
    private var frame: CGRect
    private weak var delegate: ScrollGestureTrackerDelegate?

    private var scrollWheelState: ScrollWheelState?

    // MARK: - Initialization

    init(coarseMoveFactor: CGFloat = 10, frame: CGRect, delegate: ScrollGestureTrackerDelegate) {
        self.coarseMoveFactor = coarseMoveFactor
        self.frame = frame
        self.delegate = delegate
    }

    // MARK: - EventMonitorReceiver

    let eventMask: NSEvent.EventTypeMask = .scrollWheel

    func receive(_ event: NSEvent) -> NSEvent? {

        guard eventInsideFrame(event) else { return event }

        let move: CGSize = {
            if event.hasPreciseScrollingDeltas {
                return CGSize(width: event.scrollingDeltaX,
                              height: event.scrollingDeltaY)
            } else {
                return CGSize(width: event.deltaX * coarseMoveFactor,
                              height: event.deltaY * coarseMoveFactor)
            }
        }()

        func began(_ e: NSEvent) -> Bool {
            e.phase.contains(.changed)
        }

        func changed(_ e: NSEvent) -> Bool {
            e.phase.contains(.changed)
        }

        switch scrollWheelState {
        case nil:
            if began(event) {
                scrollWheelState = .prev(timestamp: event.timestamp, translation: .zero, velocity: .zero)
            }
        case .prev(let timestamp, let translation, let velocity)?:
            let dT = event.timestamp - timestamp
            let newVelocity = CGSize(width: -move.width / dT, height: -move.height / dT)
            let newTranslation = calcNewTranslation(move: move, translation: translation)

            func notifyGestureChange() {
                scrollWheelState = .prev(timestamp: event.timestamp, translation: newTranslation, velocity: newVelocity)
                if move.width.magnitude > 0 || move.height.magnitude > 0 {
                    delegate?.scrollGestureChanged(event.locationInWindow, newTranslation, velocity)
                }
            }

            func endGesture() {
                scrollWheelState = nil
                delegate?.scrollGestureEnded(event.locationInWindow, newTranslation, velocity)
            }

            if changed(event) {
                notifyGestureChange()
            } else {
                endGesture()
            }
        }

        return event
    }

    // MARK: - Helpers

    private func calcNewTranslation(move: CGSize, translation: CGSize) -> CGSize {
        CGSize(width: translation.width + move.width, height: translation.height + move.height)
    }

    private func eventInsideFrame(_ event: NSEvent) -> Bool {
        frame.contains(event.locationInWindow)
    }

    // MARK: - Types

    private enum ScrollWheelState {
        case prev(timestamp: TimeInterval, translation: CGSize, velocity: CGSize)
    }
}
