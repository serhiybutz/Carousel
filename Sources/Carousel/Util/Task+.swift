//
//  Task+.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-26.
//

import Foundation

extension Task where Success == Never, Failure == Never {

    static func sleep(seconds duration: TimeInterval) async throws {

        try await sleep(nanoseconds: duration.asNanoseconds)
    }
}

extension TimeInterval {

    var asNanoseconds: UInt64 { UInt64(self * 1_000_000_000) }
}
