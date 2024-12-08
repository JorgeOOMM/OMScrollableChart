// Copyright 2018 Jorge Ouahbi
//
// Licensed under the Apache License, Version 2.0 (the "License")
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

import Foundation
import UIKit

extension UIView {
    func growAnimation(duration: CFTimeInterval) -> CAKeyframeAnimation {
        let boundsOvershootAnimation = CAKeyframeAnimation(keyPath: "transform")
        
        let startingScale   = CATransform3DScale(layer.transform, 0, 0, 0)
        let overshootScale  = CATransform3DScale(layer.transform, 1.3, 1.3, 1.0)
        let undershootScale = CATransform3DScale(layer.transform, 0.9, 0.9, 1.0)
        let overshootScale2  = CATransform3DScale(layer.transform, 1.2, 1.2, 1.0)
        let undershootScale2 = CATransform3DScale(layer.transform, 0.8, 0.8, 1.0)
        let endingScale     = layer.transform
        
        boundsOvershootAnimation.duration = duration
        
        boundsOvershootAnimation.values = [NSValue(caTransform3D: startingScale),
                                           NSValue(caTransform3D: overshootScale),
                                           NSValue(caTransform3D: undershootScale),
                                           NSValue(caTransform3D: overshootScale2),
                                           NSValue(caTransform3D: undershootScale2),
                                           NSValue(caTransform3D: endingScale)]
        
        boundsOvershootAnimation.keyTimes = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0].map{ NSNumber(value: $0) }
        
        boundsOvershootAnimation.timingFunctions = [
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut),
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        ]
        
        boundsOvershootAnimation.fillMode = .forwards
        boundsOvershootAnimation.isRemovedOnCompletion = false
        return boundsOvershootAnimation
        
    }
    
    func grow(duration: CFTimeInterval) {
        self.layer.add(growAnimation(duration: duration),
                       forKey: "keyFrameGrowAnimation")
    }
    
    func shakeGrow(duration: CFTimeInterval) {
        self.layer.add(shakeGrowAnimation(duration: duration),
                       forKey: "shakeGrowAnimation")
    }
    public func shakeGrowAnimation(duration: CFTimeInterval) -> CAAnimation {
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        translation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        translation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
        
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0].map {
            ( degrees: Double) -> Double in
            let radians: Double = (Double.pi * degrees) / 180.0
            return radians
        }
        let shakeGroup: CAAnimationGroup = CAAnimationGroup()
        shakeGroup.animations = [growAnimation(duration: duration),
                                 translation,
                                 rotation,
                                 translation,
                                 growAnimation(duration: duration)]
        shakeGroup.duration = duration
        return shakeGroup
    }
}
