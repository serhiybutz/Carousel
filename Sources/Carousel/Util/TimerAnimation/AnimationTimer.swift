//
//  AnimationTimer.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import OSLog

final class AnimationTimer {
    // MARK: - Properties

#if os(macOS)
    private let displayLink = DisplayLink()!
#elseif os(iOS)
    private let displayLink = DisplayLink()
#endif

    // MARK: - Initialization

    init(tick: @escaping () -> Void) {
        self.displayLink.callback = { [weak self] in
            guard let _ = self else { return }
            tick()
        }
    }

    // MARK: - API

    func start() {
        displayLink.start()
    }

    func stop() {
        displayLink.cancel()
    }

    deinit {
        displayLink.cancel()
    }
}
