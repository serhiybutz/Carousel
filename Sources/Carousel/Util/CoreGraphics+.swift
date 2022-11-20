//
//  CoreGraphics+.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import CoreGraphics

extension CGSize {
    func modified(handler: (Self) -> Self) -> Self {
        handler(self)
    }
}

extension CGPoint {
    func modified(handler: (Self) -> Self) -> Self {
        handler(self)
    }
}
