//
//  CrossFadeParameters.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-20.
//

import Foundation
import CoreGraphics

struct CrossFadeParameters {
    // MARK: - Properties

    let fadeOutIdx: Int
    let fadeInIdx: Int
    let fadeInOpacity: CGFloat

    // MARK: - Initialization
    
    init?(geometry: GeometryParameters, wheelAngle: CGFloat) {

        let wheelParameters = geometry.wheelParameters

        if let leftIdx = geometry.nearestStepIdx(byAngle: wheelAngle, neighborSelectionRule: .left),
           let rightIdx = geometry.nearestStepIdx(byAngle: wheelAngle, neighborSelectionRule: .right)
        {
            let left = (wheelParameters.yProjection(ofItemAt: leftIdx, withOriginAngle: wheelAngle), leftIdx)
            let right = (wheelParameters.yProjection(ofItemAt: rightIdx, withOriginAngle: wheelAngle), rightIdx)
            let seq = [left, right]
                .sorted(by: { $0.0 > $1.0 })
            fadeOutIdx = seq.map(\.1).first!
            fadeInIdx = seq.map(\.1).last!
            let maxCrossfadeRange = wheelParameters.radius - cos(wheelParameters.angleStep) * wheelParameters.radius
            let crossFadeRange = maxCrossfadeRange * Const.CrossFade.rangeRatio
            fadeInOpacity = (1 - min((left.0 - right.0).magnitude, crossFadeRange) / crossFadeRange) / 2 * Const.CrossFade.opacityCorrection // opacity
        } else {
            return nil
        }
    }
}
