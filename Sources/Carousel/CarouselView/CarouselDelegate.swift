//
//  CarouselDelegate.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import SwiftUI

public protocol CarouselDelegate: AnyObject {
    func carouselActiveChanged(newIdx: Int)
    func carouselActiveClicked(idx: Int)
    func carouselActiveDoubleClicked(idx: Int)
}

extension CarouselDelegate {
    public func carouselActiveChanged(newIdx: Int) {}
    public func carouselActiveClicked(idx: Int) {}
    public func carouselActiveDoubleClicked(idx: Int) {}
}
