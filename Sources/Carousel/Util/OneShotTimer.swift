//
//  OneShotTimer.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-25.
//

import Foundation

final class OneShotTimer {

    private var task: Task<(), Never>!

    init(interval: TimeInterval, fire: @escaping () -> Void) {
        self.task = Task.detached {
            do {
                try await Task.sleep(seconds: interval)
                fire()
            } catch {}
        }
    }

    deinit {
        task.cancel()
    }
}
