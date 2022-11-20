//
//  Comparable+Utils.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation

extension Comparable {

    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
