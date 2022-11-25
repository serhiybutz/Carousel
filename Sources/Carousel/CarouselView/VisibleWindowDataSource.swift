//
//  VisibleWindowDataSource.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation
import CoreGraphics

protocol VisibleWindowDataSource: AnyObject {
    associatedtype ItemView
    func itemView(for idx: Int) -> ItemView
    func offset(at idx: Int) -> CGSize
    func zoomFactor(at idx: Int) -> CGFloat
    func zIndex(at idx: Int) -> CGFloat
    var visibleIndices: ClosedRange<Int>? { get }
}
