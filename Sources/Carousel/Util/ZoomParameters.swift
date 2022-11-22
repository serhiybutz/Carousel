//
//  ZoomParameters.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import Foundation
import CoreGraphics

struct ZoomParameters {
    // MARK: - Properties

    private let linkUp: CubicBezierCurvesLinkUp
    private let dim: CGFloat

    // MARK: - Initialization

    init(dim: CGFloat) {
        self.dim = dim
        self.linkUp = CubicBezierCurvesLinkUp(
            startCoord: CGPoint(x: 0, y: 1),
            continuations: [
                (handle1: CGPoint(x: 0.07, y: 1), handle2: CGPoint(x: 0.1, y: 0.97), nextCoord: CGPoint(x: 0.13, y: 0.73)),
                (handle1: CGPoint(x: 0.13, y: 0.4), handle2: CGPoint(x: 0.5, y: 0), nextCoord: CGPoint(x: 1, y: 0))
            ])!
    }

    // MARK: - API
    
    func getZoom(for projection: CGFloat) -> CGFloat? {
        let x = projection.magnitude / dim
        if let coeff = linkUp.getY(at: x) {
            return Const.View.zoomFactor * coeff + (1 - Const.View.zoomFactor)
        } else { return nil }
    }
}
