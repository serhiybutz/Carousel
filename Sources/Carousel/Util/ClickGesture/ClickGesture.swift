//
//  ClickGesture.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import SwiftUI

// https://stackoverflow.com/questions/56513942/how-to-detect-a-tap-gesture-location-in-swiftui#answer-66504244

struct ClickGesture: Gesture {
    // MARK: - Properties

    private let count: Int
    private let coordinateSpace: CoordinateSpace

    typealias Value = SimultaneousGesture<TapGesture, DragGesture>.Value

    // MARK: - Initialization

    init(count: Count = .init(1)!, coordinateSpace: CoordinateSpace = .local) {

        self.count = count.value
        self.coordinateSpace = coordinateSpace
    }

    // MARK: - Lifecycle

    var body: SimultaneousGesture<TapGesture, DragGesture> {

        SimultaneousGesture(
            TapGesture(count: count),
            DragGesture(minimumDistance: 0, coordinateSpace: coordinateSpace)
        )
    }

    // MARK: - API

    func onEnded(perform action: @escaping (CGPoint) -> Void) -> _EndedGesture<ClickGesture> {

        self.onEnded { (value: Value) -> Void in
            guard value.first != nil else { return }
            guard let location = value.second?.startLocation else { return }
            guard let endLocation = value.second?.location else { return }
            guard ((location.x - 1)...(location.x + 1)).contains(endLocation.x),
                  ((location.y - 1)...(location.y + 1)).contains(endLocation.y) else {
                return
            }
            action(location)
        }
    }
}

extension View {

    func onClickGesture(
        count: Count,
        coordinateSpace: CoordinateSpace = .local,
        perform action: @escaping (CGPoint) -> Void
    ) -> some View {
        gesture(ClickGesture(count: count, coordinateSpace: coordinateSpace)
            .onEnded(perform: action)
        )
    }

    func onClickGesture(
        count: Count,
        perform action: @escaping (CGPoint) -> Void
    ) -> some View {
        onClickGesture(count: count, coordinateSpace: .local, perform: action)
    }

    func onClickGesture(
        perform action: @escaping (CGPoint) -> Void
    ) -> some View {
        onClickGesture(count: .init(1)!, coordinateSpace: .local, perform: action)
    }
}
