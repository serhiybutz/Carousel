//
//  KeyboardListener.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import AppKit
import Carbon.HIToolbox

protocol KeyboardListenerDelegate: AnyObject {
    func keyUp(_ key: KeyboardListener.Key)
    func keyDown(_ key: KeyboardListener.Key)
}

final class KeyboardListener: EventMonitorReceiver {
    // MARK: - Properties

    private weak var delegate: KeyboardListenerDelegate?

    // MARK: - Initialization

    init(delegate: KeyboardListenerDelegate) {
        self.delegate = delegate
    }

    // MARK: - EventMonitorReceiver

    let eventMask: NSEvent.EventTypeMask = [.keyUp, .keyDown]

    func receive(_ event: NSEvent) -> NSEvent? {

        switch event.type {
        case .keyDown:
            delegate?.keyDown(Key(byVirtualKeycode: Int(event.keyCode)))
        case .keyUp:
            delegate?.keyUp(Key(byVirtualKeycode: Int(event.keyCode)))
        default:
            preconditionFailure()
        }
        return nil
    }

    // MARK: - Types

    enum Key: Hashable {
        case rightArrow, leftArrow, unknown(Int)

        static let keyByVirtKeycode: [Int: Key] = [
            kVK_RightArrow: .rightArrow,
            kVK_LeftArrow: .leftArrow
        ]

        init(byVirtualKeycode keycode: Int) {
            if let key = Key.keyByVirtKeycode[keycode] {
                self = key
            } else {
                self = Key.unknown(keycode)
            }
        }
    }
}
