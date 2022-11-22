//
//  CarouselView.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import SwiftUI

public struct CarouselView<T: CarouselDataSource>: View {

    @StateObject var viewModel: CarouselViewModel<T>

    public init(dataSource: T, delegate: CarouselDelegate? = nil, initialActiveIdx: Int = 0, wheelRadius: CGFloat? = nil, angleStep: CGFloat = Defaults.Wheel.angleStep, itemSize: CGSize = .init(width: 100, height: 200)) {
        let args = CarouselViewModel<T>.Args(
            dataSource: dataSource,
            delegate: delegate,
            initialActiveIdx: initialActiveIdx,
            itemSize: itemSize,
            wheelRadius: wheelRadius ?? itemSize.width * 3,
            angleStep: angleStep)
        self._viewModel = StateObject(wrappedValue: CarouselViewModel(args: args))
    }

    public var body: some View {
        ZStack {
            if let innerViewModel = viewModel.carouselViewModelInner {
                CarouselViewInner(viewModel: innerViewModel)
            } else {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .getViewFrame(controller: viewModel.viewFrameModifierController) { frame in
            viewModel.frame = frame
        }
        .clipped()
    }
}
