//
//  CarouselViewInner.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import SwiftUI

/// The scope of this view matches the state scope of the geometry:
struct CarouselViewInner<T: CarouselDataSource>: View {

    var dragGesture: some Gesture {

        DragGesture.init(minimumDistance: 1)
            .onChanged { value in
                viewModel.receiveDragGestureEvent(.change(location: value.location, translation: value.translation.width, velocity: value.velocity.x))
            }
            .onEnded { value in
                viewModel.receiveDragGestureEvent(.end(location: value.location, translation: value.translation.width, velocity: value.velocity.x))
            }
    }

    @ObservedObject var viewModel: CarouselViewModelInner<T> // This state's scope is bound to the frame value (and managed in CarouselViewModel).

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let visIndices = viewModel.visibleIndices {

                ForEach(visIndices, id: \.self) { idx in
                    if let fadingInIdx = viewModel.fadingInIdx,
                       let fadingOutIdx = viewModel.fadingOutIdx,
                       idx == fadingInIdx || idx == fadingOutIdx {
                        if idx == fadingInIdx {
                            ItemView(idx: fadingInIdx, viewModel: viewModel)
                            ItemView(idx: fadingOutIdx, viewModel: viewModel)
                                .overlay(
                                    ItemView(idx: fadingInIdx, viewModel: viewModel)
                                        .opacity(viewModel.fadingProgress)
                                        .mask(
                                            Group {
                                                Rectangle()
                                                    .frame(width: viewModel.itemSize.width, height: viewModel.itemSize.height)
                                                    .scaleEffect(viewModel.visible.getZoomFactor(at: fadingOutIdx))
                                                    .offset(viewModel.visible.getOffset(at: fadingOutIdx).modified {
                                                        CGSize(
                                                            width: $0.width - viewModel.itemSize.width / 2,
                                                            height: $0.height - viewModel.itemSize.height / 2
                                                        )
                                                    })
                                            }
                                        )
                                )
                            }
                    } else {
                        ItemView(idx: idx, viewModel: viewModel)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .simultaneousGesture(ClickGesture(count: .init(2)!).onEnded {
            viewModel.receiveTap(.double, $0)
        })
        .simultaneousGesture(ClickGesture().onEnded {
            viewModel.receiveTap(.single, $0)
        })
    }
}

struct ItemView<T: CarouselDataSource>: View {

    let idx: Int
    @ObservedObject var viewModel: CarouselViewModelInner<T>

    let zIndex: CGFloat

    init(idx: Int, viewModel: CarouselViewModelInner<T>) {
        self.idx = idx
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.zIndex = viewModel.visible.getZIndex(at: idx)
    }

    var body: some View {

        viewModel.itemView(for: idx)
            .frame(width: viewModel.itemSize.width, height: viewModel.itemSize.height)
            .scaleEffect(viewModel.visible.getZoomFactor(at: idx))
            .offset(viewModel.visible.getOffset(at: idx).modified {
                CGSize(
                    width: $0.width - viewModel.itemSize.width / 2,
                    height: $0.height - viewModel.itemSize.height / 2
                )
            })
            .zIndex(zIndex)
    }
}
