//
//  AnimationTimer.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import AppKit
import Combine
import OSLog

final class AnimationTimer {
    // MARK: - Properties

    private let displayLink = DisplayLink()! // TODO: Rework to throw

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
