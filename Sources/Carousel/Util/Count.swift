//
//  Count.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation

struct Count {
    // MARK: - Properties

    let value: Int

    // MARK: - Initialization
    
    init?(_ value: Int) {
        guard 1... ~= value else { return nil }
        self.value = value
    }
}
