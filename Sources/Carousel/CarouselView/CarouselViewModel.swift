//
//  CarouselViewModel.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import SwiftUI

@MainActor
public final class CarouselViewModel<T: CarouselDataSource>: ObservableObject {
    // MARK: - Properties

    let args: Args
    let viewFrameModifierController = GetViewFrameModifier.Controller(inCoordinateSpace: .global)
    var frame: CGRect? {
        didSet {
            guard oldValue != frame else { return }
            updateFrameDepsIfNeeded()
        }
    }

    private(set) var activeIdx: Int

    @Published var carouselViewModelInner: CarouselViewModelInner<T>?
#if os(macOS)
    private var eventMonitor: EventMonitor?
#endif

    // MARK: - Initialization

    init(args: Args) {
        self.args = args
        self.activeIdx = args.initialActiveIdx
    }

    // MARK: - Helpers

    private func updateFrameDepsIfNeeded() {
        if let frame = frame, frame != .zero {
            self.carouselViewModelInner = makeInnerViewModel(in: frame)
#if os(macOS)
            self.eventMonitor = makeEventMonitor(with: self.carouselViewModelInner!, in: frame)
#endif
        }
    }

    private func makeInnerViewModel(in frame: CGRect) -> CarouselViewModelInner<T> {
        let activeIdxBinding = Binding(
            get: { [unowned self] in
                self.activeIdx
            },
            set: { [unowned self] in
                self.activeIdx = $0
            })
        return CarouselViewModelInner<T>(args: args, activeIdx: activeIdxBinding, frame: frame)
    }

#if os(macOS)
    private func makeEventMonitor(with innerViewModel: CarouselViewModelInner<T>, in frame: CGRect) -> EventMonitor {
        let scrollGestureTracker = ScrollGestureTracker(frame: frame, delegate: innerViewModel)
        let keyboardListener = KeyboardListener(delegate: innerViewModel)
        let tapListener = SimpleTapListener(delegate: innerViewModel)
        return EventMonitor(receivers: [scrollGestureTracker, keyboardListener, tapListener])
    }
#endif

    // MARK: - Types

    struct Args {
        let dataSource: T
        let delegate: CarouselDelegate?
        let initialActiveIdx: Int
        let itemSize: CGSize
        let wheelRadius: CGFloat
        let angleStep: CGFloat
    }
}
