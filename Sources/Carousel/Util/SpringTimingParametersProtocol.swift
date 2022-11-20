//
//  SpringTimingParametersProtocol.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation

protocol SpringTimingParametersProtocol {
    var duration: TimeInterval { get }
    func value(at time: TimeInterval) -> CGFloat
}
