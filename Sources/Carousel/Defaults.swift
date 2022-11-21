//
//  Defaults.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation
import CoreGraphics

public enum Defaults {
    public enum Wheel {
#if os(macOS)
        public static let angleStep: CGFloat = CGFloat.pi / 2 / 7
#elseif os(iOS)
        public static let angleStep: CGFloat = CGFloat.pi / 2 / 14
#endif
    }
}
