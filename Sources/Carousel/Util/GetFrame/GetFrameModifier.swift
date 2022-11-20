//
//  GetViewFrameModifier.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import SwiftUI

struct GetViewFrameModifier: ViewModifier {
    // MARK: - Properties

    @ObservedObject // <-- Not using @StateObject for explicit state scope control
    private var controller: Controller
    private let action: Action

    // MARK: - Initialization

    init(controller: Controller, action: @escaping Action) {
        self.controller = controller
        self.action = action
    }

    // MARK: - Lifecycle

    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color
                    .clear
                    .preference(key: ViewFramePreferenceKey.self,
                                value: geometry.frame(in: controller.coordinateSpace))
            })
            .onAppear {
                controller.action = action
            }
            .onPreferenceChange(ViewFramePreferenceKey.self) {
                controller.setFrame($0)
            }
    }

    // MARK: - Types

    @MainActor
    final class Controller: ObservableObject {
        // MARK: - Properties

        let coordinateSpace: CoordinateSpace
        fileprivate var action: Action?
        private var backingFrame: CGRect = .zero
        fileprivate(set) var frame: CGRect = .zero

        // MARK: - Initialization

        init(inCoordinateSpace coordinateSpace: CoordinateSpace = .local) {
            self.coordinateSpace = coordinateSpace
        }

        // MARK: - API

        func setFrame(_ frame: CGRect) {
            backingFrame = frame
            Task {
                update()
            }
        }

        // MARK: - Helpers

        private func update() {
            guard frame != backingFrame else { return }
            frame = backingFrame
            action?(frame)
        }
    }

    // MARK: - Types

    private struct ViewFramePreferenceKey: PreferenceKey {
        static var defaultValue: CGRect = .zero
        static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
    }

    typealias Action = (CGRect) -> Void
}

extension View {

    func getViewFrame(controller: GetViewFrameModifier.Controller, perform action: @escaping (CGRect) -> Void) -> some View {
        self
            .modifier(GetViewFrameModifier(controller: controller, action: action))
    }
}
