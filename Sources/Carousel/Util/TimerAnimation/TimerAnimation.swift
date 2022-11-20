//
//  TimerAnimation.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import QuartzCore

public final class TimerAnimation {
    // MARK: - Properties

    private let duration: TimeInterval
    private let animations: Animations
    private let completion: Completion?
    private var animationTimer: AnimationTimer!

    private var isRunning: Bool = true

    private let firstFrameTimestamp: TimeInterval

    // MARK: - Initialization

    init(duration: TimeInterval, animations: @escaping Animations, completion: Completion? = nil) {

        self.duration = duration
        self.animations = animations
        self.completion = completion

        firstFrameTimestamp = CACurrentMediaTime()

        self.animationTimer = AnimationTimer { [weak self] in
            guard let self = self else { return }
            self.handleFrame()
        }
        self.animationTimer.start()
    }

    deinit {
        stop()
    }

    // MARK: - API

    func stop() {
        
        guard isRunning else { return }
        isRunning = false
        animationTimer.stop()
        completion?(false)
    }

    // MARK: - Helpers

    private func handleFrame() {

        guard isRunning else { return }

        let elapsed = CACurrentMediaTime() - firstFrameTimestamp
        if elapsed >= duration {
            animations(1, duration)
            isRunning = false
            completion?(true)
            animationTimer.stop()
        } else {
            animations(elapsed / duration, elapsed)
        }
    }

    // MARK: - Types

    typealias Animations = (_ progress: Double, _ time: TimeInterval) -> Void
    typealias Completion = (_ isFinished: Bool) -> Void
}
