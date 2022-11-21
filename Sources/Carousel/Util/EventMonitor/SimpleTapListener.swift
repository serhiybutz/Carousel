//
//  SimpleTapListener.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

#if os(macOS)
import AppKit

protocol SimpleTapListenerDelegate: AnyObject {
    func tapped(_ phase: SimpleTapListener.Phase, _ location: CGPoint)
}

final class SimpleTapListener: EventMonitorReceiver {
    // MARK: - Properties

    private weak var delegate: SimpleTapListenerDelegate?

    // MARK: - Initialization

    init(delegate: SimpleTapListenerDelegate) {
        self.delegate = delegate
    }

    // MARK: - EventMonitorReceiver

    let eventMask: NSEvent.EventTypeMask = [.leftMouseDown, .leftMouseUp]

    func receive(_ event: NSEvent) -> NSEvent? {
        switch event.type {
        case .leftMouseDown:
            delegate?.tapped(.down, event.locationInWindow)
        case .leftMouseUp:
            delegate?.tapped(.up, event.locationInWindow)
        default:
            preconditionFailure()
        }
        return event
    }

    // MARK: - Types

    enum Phase: Hashable {
        case down, up
    }
}
#endif
