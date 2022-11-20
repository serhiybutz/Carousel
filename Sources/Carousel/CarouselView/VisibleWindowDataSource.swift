//
//  VisibleWindowDataSource.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation

protocol VisibleWindowDataSource: AnyObject {
    associatedtype ItemView
    func itemView(for idx: Int) -> ItemView
    func getOffset(at idx: Int) -> CGSize
    func getZoomFactor(at idx: Int) -> CGFloat
    func getZIndex(at idx: Int) -> CGFloat
    var visibleIndices: ClosedRange<Int>? { get }
}
