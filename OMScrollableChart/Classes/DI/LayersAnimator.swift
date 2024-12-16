// Copyright 2018 Jorge Ouahbi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import Accelerate
import GUILib
// swiftlint:disable file_length
// swiftlint:disable type_body_length

class LayersAnimator: NSObject, LayersAnimatorProtocol, CAAnimationDelegate {

    var ridePathAnimation: CAAnimation? = nil
    var layerToRide: CALayer?
    var ridePath: Path?
    
    func pathRideToPointAnimation( cgPath: CGPath,
                                    percent: CFloat ,
                                   timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                   duration: TimeInterval) -> CAAnimation? {
        return pathRideAnimation(cgPath: cgPath,
                                 percent: percent,
                                 duration: duration)
    }
    
    func pathRideToPoint(cgPath: CGPath, percent: CFloat, timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)) -> CGPoint {
        self.ridePath = Path(withTimingFunction: timingFunction)
        let point =  self.ridePath?.pointForPercentage(pathPercent: Double(percent)) ?? .zero
        return point
    }
    func pathRideAnimation( cgPath: CGPath,
                            percent: CFloat,
                            timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                            duration: TimeInterval) -> CAAnimation? {
        self.ridePath = Path(withTimingFunction: timingFunction)
        let timesForFourthOfAnimation: Double
        if let curveLengthPercentagesForFourthOfAnimation = ridePath?.percentagesWhereYIs(y: Double(percent)) {
            if curveLengthPercentagesForFourthOfAnimation.count > 0 {
                if let originX = ridePath?.pointForPercentage(pathPercent: curveLengthPercentagesForFourthOfAnimation[0])?.x {
                    timesForFourthOfAnimation = Double(originX)
                } else {
                    timesForFourthOfAnimation = 1
                }
            } else {
                timesForFourthOfAnimation = 1
            }
            let anim = CAKeyframeAnimation(keyPath: "position")
            anim.path = cgPath
            anim.rotationMode = CAAnimationRotationMode.rotateAuto
            anim.fillMode = CAMediaTimingFillMode.forwards
            anim.duration = duration
            anim.timingFunction = timingFunction
            anim.isRemovedOnCompletion = false
            anim.delegate = self
            
            anim.repeatCount = Float(timesForFourthOfAnimation)
            return anim
        }
        return nil
    }
    /// animateLayerPathRideToPoint
    /// - Parameters:
    ///   - path: UIBezierPath
    ///   - layerToRide: CALayer
    ///   - pointIndex: Int
    ///   - duration: TimeInterval
    /// - Returns: CAAnimation
    func animateLayerPathRideToPoint(_ path: UIBezierPath,
                                     layerToRide: CALayer,
                                     percent: CFloat,
                                     duration: TimeInterval = 10.0) -> CAAnimation {
        self.layerToRide = layerToRide
        self.ridePathAnimation = pathRideToPointAnimation(cgPath: path.cgPath,
                                                          percent: percent,
                                                          duration: duration)
        let anim = CABasicAnimation(keyPath: "rideProgress")
        anim.fromValue = NSNumber(value: 0)
        anim.toValue   = NSNumber(value: 1.0)
        anim.fillMode = .forwards
        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        anim.isRemovedOnCompletion = false
        anim.delegate = self
        
        return anim
    }
    
    func animateLayerPath( _ shapeLayer: CAShapeLayer,
                           pathStart: UIBezierPath,
                           pathEnd: UIBezierPath,
                           duration: TimeInterval = 0.5) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue     = pathStart.cgPath
        animation.toValue       = pathEnd.cgPath
        animation.duration      = duration
        animation.isRemovedOnCompletion  = true
        animation.fillMode = .forwards
        animation.delegate      = self
        animation.completion = {  finished in
            CATransaction.withDisabledActions({
                shapeLayer.path = pathEnd.cgPath
            })
        }
        return animation
    }
}


