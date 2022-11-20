//
//  CarouselDataSource.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import SwiftUI

public protocol CarouselDataSource: AnyObject {
    associatedtype ItemView: View
    var carouselItemCount: Int { get }
    func carouselItemView(for idx: Int) -> ItemView
}
