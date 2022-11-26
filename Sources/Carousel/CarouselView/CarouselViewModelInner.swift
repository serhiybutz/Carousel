//
//  CarouselViewModelInner.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import SwiftUI
import Combine

@MainActor
public final class CarouselViewModelInner<T: CarouselDataSource>: ObservableObject {

    // MARK: - Properties

    @Published var state: State = .idle

    private weak var dataSource: T?
    private weak var delegate: CarouselDelegate?

    @Binding
    var activeIdx: Int

    let frame: CGRect

    var bounds: CGRect {
        CGRect(origin: .zero, size: frame.size)
    }

    var visCenter: CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }

    // The angle between the screen center and the origin wheel pos
    @Published var wheelAngle: CGFloat {
        didSet {
            guard oldValue != wheelAngle else { return }
            updateActiveIdxIfNeeded()
        }
    }

    var circleOffset: CGFloat {
        get {
            makeGeometryParameters()
                .wheelParameters
                .circleOffset(forAngle: wheelAngle)
        }
        set {
            wheelAngle = makeGeometryParameters()
                .wheelParameters
                .angle(forCircleOffset: newValue)

            updateCrossFadeAnimation()
        }
    }

    let wheelRadius: CGFloat
    let angleStep: CGFloat
    let itemSize: CGSize

    private(set) var startDragCircleOffset: CGFloat?
    private(set) var startScrollCircleOffset: CGFloat?

    private(set) var isDraggingHolding: Bool = false

    @Published var crossFadeState: CrossFadeParameters?

    // MARK: - Initialization

    init(args: CarouselViewModel<T>.Args, activeIdx: Binding<Int>, frame: CGRect) {

        let bounds = CGRect(origin: .zero, size: frame.size)
        let geometry = Self.makeGeometryParameters(
            bounds: bounds,
            wheelRadius: args.wheelRadius,
            angleStep: args.angleStep,
            itemSize: args.itemSize,
            itemsCount: args.dataSource.carouselItemCount)

        self.dataSource = args.dataSource
        self.delegate = args.delegate
        self.wheelRadius = args.wheelRadius
        self.angleStep = args.angleStep
        self.itemSize = args.itemSize
        self.frame = frame

        self._activeIdx = activeIdx
        self.wheelAngle = geometry.angle(forItemIdx: activeIdx.wrappedValue)
    }

    // MARK: - API

    var visible: some VisibleWindowDataSource { self }

    func receiveDragGestureEvent(_ event: GestureEvent) {

        resetWheelMomentum()

        switch event {
        case let .change(location, translation, _):
            if startDragCircleOffset == nil {

                resetWheelMomentum()
                startDragCircleOffset = circleOffset

                self.isDraggingHolding = bounds.contains(location)
                && visibleIndices?.contains(where: { itemFrame(at: $0).contains(location) }) ?? false
            }

            if isDraggingHolding {
                let distance = startDragCircleOffset! - translation
                circleOffset = makeRubberBandParameters()
                    .clamp(distance)
            }
        case let .end(_, _, velocity):
            if isDraggingHolding {
                acomplishWheelMomentum(-velocity)
                startDragCircleOffset = nil
                isDraggingHolding = false
            }
        }
    }

    // MARK: - Helpers

    private func updateActiveIdxIfNeeded() {
        let newActiveIdx = makeGeometryParameters()
            .activeIdx(byAngle: wheelAngle)
        if activeIdx != newActiveIdx {
            activeIdx = newActiveIdx
            delegate?.carouselActiveChanged(newIdx: newActiveIdx)
        }
    }

    func updateCrossFadeAnimation() {
        let geometry = makeGeometryParameters()
        self.crossFadeState = CrossFadeParameters(geometry: geometry, wheelAngle: wheelAngle)
    }

    private func calcZoomFactor(_ x: CGFloat) -> CGFloat? {
        makeZoomParameters().getZoom(for: x - dim / 2)
    }

    private func acomplishWheelMomentum(_ dragVelocity: CGFloat) {

        let wheelMomentum = WheelMomentum(initialVelocity: -dragVelocity, delegate: self) { [weak self] in
            guard let self = self else { return }
            self.resetWheelMomentum()
        }
        state = .wheelRotating(wheelMomentum)
    }
}

extension CarouselViewModelInner {
    // MARK: - Helpers

    private func makeGeometryParameters() -> GeometryParameters {

        Self.makeGeometryParameters(
            bounds: bounds,
            wheelRadius: wheelRadius,
            angleStep: angleStep,
            itemSize: itemSize,
            itemsCount: itemsCount)
    }

    private static func makeGeometryParameters(bounds: CGRect, wheelRadius: CGFloat, angleStep: CGFloat, itemSize: CGSize, itemsCount: Int) -> GeometryParameters {

        guard let itemsCount = Count(itemsCount) else { preconditionFailure("Items count must be at least 1!") }

        return GeometryParameters(
            bounds: bounds,
            wheelRadius: wheelRadius,
            itemSize: itemSize,
            itemsCount: itemsCount,
            angleStep: angleStep)
    }

    private func makeRubberBandParameters() -> RubberBandParameters {

        let rubberBandDisplacement = makeGeometryParameters()
            .wheelParameters
            .circleOffset(forAngle: Const.Behavior.rubberBandDisplacementAngle)
        return RubberBandParameters(bounds: circleOffsetBounds, displacement: rubberBandDisplacement)
    }

    private func makeZoomParameters() -> ZoomParameters {
        ZoomParameters(dim: dim / 2)
    }

    // Mouse coordinate space originates from the bottom left corner of the window,
    // while the frame originates from the top left corner of the window:
    private func convertFromScrollWheelCoordinateSpace(_ location: CGPoint) -> CGPoint {
        CGPoint(x: location.x - frame.origin.x,
                y: frame.height - location.y)
    }
}

extension CarouselViewModelInner {

    var circleOffsetBounds: ClosedRange<CGFloat> {

        let geometry = makeGeometryParameters()
        let angleBounds = geometry
            .fullAngleRange(addingExtraAngle: .pi / 2)
        return 0...geometry.wheelParameters.circleOffset(forAngle: angleBounds.upperBound)
    }

    var dim: CGFloat { bounds.width }

    var itemsCount: Int { dataSource?.carouselItemCount ?? 0 }
}

extension CarouselViewModelInner: VisibleWindowDataSource {

    var visibleIndices: ClosedRange<Int>? {

        let indices = makeGeometryParameters()
            .visibleIndices(for: wheelAngle)
        var startIdx: Int?, endIdx: Int?
        for idx in indices {
            let fr = itemFrame(at: idx)
            if startIdx == nil {
                if fr.intersects(bounds) {
                    startIdx = idx
                }
            }
            if startIdx != nil {
                if fr.intersects(bounds) {
                    endIdx = idx
                } else {
                    break
                }
            }
        }
        if let startIdx = startIdx, let endIdx = endIdx {
            return startIdx...endIdx
        } else {
            return nil
        }
    }

    func itemView(for idx: Int) -> T.ItemView? {
        dataSource?.carouselItemView(for: idx)
    }

    func offset(at idx: Int) -> CGSize {
        makeGeometryParameters()
            .offset(ofItemAt: idx, withOriginAngle: wheelAngle)
    }

    func zoomFactor(at idx: Int) -> CGFloat {
        calcZoomFactor(offset(at: idx).width) ?? (1 - Const.View.zoomFactor)
    }

    func zIndex(at idx: Int) -> CGFloat {

        let radius = dim / 2
        let wheelParams = WheelParameters(radius: radius, angleStep: angleStep)
        let yProjection = wheelParams.yProjection(ofItemAt: idx, withOriginAngle: wheelAngle)
        return yProjection / radius
    }

    func itemFrame(at idx: Int) -> CGRect {

        let zoomFactor = zoomFactor(at: idx)
        let origin = offset(at: idx).modified {
            CGSize(
                width: $0.width - zoomFactor * itemSize.width / 2,
                height: $0.height - zoomFactor * itemSize.height / 2
            )
        }
        let frame = CGRect(
            origin: CGPoint(x: origin.width, y: origin.height),
            size: CGSize(width: itemSize.width * zoomFactor, height: itemSize.height * zoomFactor)
        )
        return frame
    }
}

extension CarouselViewModelInner: WheelMomentumDelegate {

    func anchor(by idx: Int) -> CGFloat {
        makeGeometryParameters()
            .circleOffsetAnchor(forItemAt: idx)
    }

    func nearestAnchor(to projection: CGFloat) -> CGFloat {
        makeGeometryParameters()
            .nearestCircleOffsetAnchor(toCircleOffsetProjection: projection)
    }
}

#if os(macOS)
extension CarouselViewModelInner: ScrollGestureTrackerDelegate {

    func scrollGestureChanged(_ location: CGPoint, _ translation: CGSize, _ velocity: CGSize) {

        receiveScrollWheelEvent(.change(
            location: location.modified { convertFromScrollWheelCoordinateSpace($0) },
            translation: translation.width,
            velocity: velocity.width))
    }

    func scrollGestureEnded(_ location: CGPoint, _ translation: CGSize, _ velocity: CGSize) {

        receiveScrollWheelEvent(.end(
            location: location.modified { convertFromScrollWheelCoordinateSpace($0) },
            translation: translation.width,
            velocity: velocity.width))
    }

    private func receiveScrollWheelEvent(_ event: GestureEvent) {

        resetWheelMomentum()

        switch event {
        case let .change(location, translation, _):

            if startScrollCircleOffset == nil {
                resetWheelMomentum()

                let isInBounds = bounds.contains(location)
                && visibleIndices?.contains(where: { itemFrame(at: $0).contains(location) }) ?? false

                guard isInBounds else { return }

                startScrollCircleOffset = circleOffset
            }
            let distance = startScrollCircleOffset! - translation
            circleOffset = makeRubberBandParameters()
                .clamp(distance)

        case let .end(_, _, velocity):

            if startScrollCircleOffset != nil {
                acomplishWheelMomentum(-velocity)
            }
            startScrollCircleOffset = nil
        }
    }
}

extension CarouselViewModelInner: KeyboardListenerDelegate {

    func keyDown(_ key: KeyboardListener.Key) {
        switch key {
        case .leftArrow:
            jump(toItemIdx: activeIdx - 1)
        case .rightArrow:
            jump(toItemIdx: activeIdx + 1)
        default: break
        }
    }

    func keyUp(_ key: KeyboardListener.Key) {
        // noop
    }
}
#endif

extension CarouselViewModelInner {

    func tappedDown(at location: CGPoint) {

        switch state {
        case .wheelRotating:
            // The click was made while the gesture animation was running:
            switch Const.Behavior.touchWhileMovingBehavior {
            case .jumpToClickLocation:
                if let idx = getIdx(at: location) {
                    jump(toItemIdx: idx)
                }
            case .jumpToCurrentCenterPosition:
                jump(to: circleOffset)
            }
        case .singleClick:
            state = .doubleClick
            delegate?.carouselActiveDoubleClicked(idx: activeIdx)
        default: break
        }
    }

    func tappedUp(at location: CGPoint) {

        switch state {
        case .idle:
            // The click was made when the wheel was still:
            if let idx = getIdx(at: location) {
                if idx == activeIdx {
                    let timer = OneShotTimer(interval: 0.5) { [weak self] in
                        Task {
                            await MainActor.run {
                                guard let self = self else { return }
                                self.state = .idle
                                self.delegate?.carouselActiveClicked(idx: self.activeIdx)
                            }
                        }
                    }
                    state = .singleClick(timer)
                } else {
                    jump(toItemIdx: idx)
                }
            }
        case .doubleClick:
            state = .idle
        default: break
        }
    }

    private func jump(to pos: CGFloat) {

        let wheelMomentum = WheelMomentum(landPos: pos, delegate: self) { [weak self] in
            guard let self = self else { return }
            self.resetWheelMomentum()
        }
        state = .wheelRotating(wheelMomentum)
    }

    private func jump(toItemIdx idx: Int) {

        let wheelMomentum = WheelMomentum(atItemIdx: idx, delegate: self) { [weak self] in
            guard let self = self else { return }
            self.resetWheelMomentum()
        }
        state = .wheelRotating(wheelMomentum)
    }

    private func getIdx(at location: CGPoint) -> Int? {

        guard let visible = visibleIndices else { return nil }

        precondition(visible ~= activeIdx)

        if itemFrame(at: activeIdx).contains(location) {
            return activeIdx
        }

        for idx in stride(from: activeIdx - 1, through: visible.lowerBound, by: -1) {
            if itemFrame(at: idx).contains(location) {
                return idx
            }
        }

        for idx in stride(from: activeIdx + 1, through: visible.upperBound, by: 1) {
            if itemFrame(at: idx).contains(location) {
                return idx
            }
        }

        return nil
    }

    private func resetWheelMomentum() {
        state = .idle
    }
}

extension CarouselViewModelInner {
    // MARK: - Types

    enum State {
        case idle
        case wheelRotating(WheelMomentum)
        case singleClick(OneShotTimer)
        case doubleClick
    }

    enum GestureEvent {
        case change(location: CGPoint, translation: CGFloat, velocity: CGFloat)
        case end(location: CGPoint, translation: CGFloat, velocity: CGFloat)
    }
}
