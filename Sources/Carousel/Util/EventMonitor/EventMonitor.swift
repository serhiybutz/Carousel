//
//  EventMonitor.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import AppKit

protocol EventMonitorReceiver {
    var eventMask: NSEvent.EventTypeMask { get }
    func receive(_ event: NSEvent) -> NSEvent?
}

final class EventMonitor {
    // MARK: - Properties

    private let monitors: [Any]

    // MARK: - Initialization

    init(receivers: [EventMonitorReceiver] = []) {
        self.monitors = receivers.map {
            NSEvent.addLocalMonitorForEvents(matching: $0.eventMask, handler: $0.receive)
        }
        .compactMap { $0 }
    }

    deinit {
        monitors.forEach {
            NSEvent.removeMonitor($0)
        }
    }
}
