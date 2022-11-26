//
//  TouchViewModifier.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-26.
//

import SwiftUI

struct TouchViewModifier: ViewModifier {

    let coordinateSpace: CoordinateSpace
    let onTouchedDown: (_ location: CGPoint) -> Void
    let onTouchedUp: (_ location: CGPoint) -> Void

    @State private var touchGestureLocation: CGPoint?

    func body(content: Content) -> some View {
        
        content
            .simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: coordinateSpace)
                .onChanged { value in
                    if touchGestureLocation == nil {
                        touchGestureLocation = value.location
                        onTouchedDown(touchGestureLocation!)
                    }
                }
                .onEnded { value in
                    if let touchGestureLocation = touchGestureLocation {
                        self.touchGestureLocation = nil
                        onTouchedUp(touchGestureLocation)
                    }
                })
    }
}

extension View {

    func onTouch(coordinateSpace: CoordinateSpace = .local,
                 onTouchedDown: @escaping (_ location: CGPoint) -> Void = {_ in},
                 onTouchedUp: @escaping (_ location: CGPoint) -> Void = {_ in}) -> some View {
        self
            .modifier(TouchViewModifier(coordinateSpace: coordinateSpace,
                                        onTouchedDown: onTouchedDown,
                                        onTouchedUp: onTouchedUp))
    }
}

