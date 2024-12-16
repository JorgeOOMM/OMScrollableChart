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

//
//  OMScrollableChart
//
//  Created by Jorge Ouahbi on 16/08/2020.

//

import UIKit
extension OMScrollableChart {
    func animateLineStrokeEnd( _ layer: CAShapeLayer,
                               fromValue: CGFloat = 0,
                               toValue: CGFloat = 1.0,
                               duration: TimeInterval = 0.4) -> CAAnimation {
        let growAnimation = CABasicAnimation(keyPath: "strokeEnd")
        growAnimation.fromValue = fromValue
        growAnimation.toValue = toValue
        growAnimation.beginTime = CACurrentMediaTime()
        growAnimation.duration = duration
        growAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        growAnimation.fillMode = .forwards
        growAnimation.isRemovedOnCompletion = false
        return growAnimation
    }
    func animateLineStrokeStartStrokeEnd( _ layer: CAShapeLayer,
                                          fromValue: CGFloat = 0,
                                          toValue: CGFloat = 1.0,
                                          rangeValue: CGFloat = 0.2,
                                          duration: TimeInterval = 0.4)  -> CAAnimation {
        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.fromValue = fromValue
        startAnimation.toValue = toValue - rangeValue
        
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = rangeValue
        endAnimation.toValue = toValue
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [startAnimation, endAnimation]
        animGroup.duration = duration
        
        animGroup.start = {
            animGroup.animations?.forEach({$0.start?()})
        }
        animGroup.completion = { finished in
            animGroup.animations?.forEach({$0.completion?(finished)})
        }
        return animGroup
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
 
    func animateLineSelection(with shapeLayer: CAShapeLayer,
                              _ newPath: UIBezierPath,
                              _ duration: TimeInterval = 0.4) -> CAAnimation {
        // the new origin of the CAShapeLayer within its view
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue =  shapeLayer.path
        animation.toValue = newPath
        animation.duration = duration
        animation.isAdditive = true
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.completion = { finished in
            CATransaction.withDisabledActions({
                shapeLayer.path = newPath.cgPath
            })
        }
        return animation
    }
    
    func animationOpacity(_ layer: CALayer,
                            fromValue: CGFloat = 0,
                            toValue: CGFloat = 1.0,
                            duration: TimeInterval = 4.0) -> CAAnimation {
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.toValue    = toValue
        fadeAnimation.fromValue  = fromValue
        fadeAnimation.fillMode   = .forwards
        fadeAnimation.duration   = duration
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.completion = { finished in
            CATransaction.withDisabledActions {
                layer.opacity = Float(toValue)
            }
        }
        return fadeAnimation
    }
        
    func animationWithFadeGroup(_ layer: CALayer,
                                fromValue: CGFloat = 0,
                                toValue: CGFloat = 1.0,
                                animations: [CAAnimation],
                                duration: TimeInterval = 1.0) -> CAAnimation {
        let duration = duration
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.toValue  = toValue
        fadeAnimation.fromValue  = fromValue
        fadeAnimation.fillMode = .forwards
        fadeAnimation.delegate = self
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.completion = { finished in
            CATransaction.withDisabledActions{
                layer.opacity = Float(toValue)
            }
        }
        let animGroup = CAAnimationGroup()
        animGroup.animations = [fadeAnimation] + animations
        animGroup.duration = duration
        animGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animGroup.delegate = self
        animGroup.start = {
            animGroup.animations?.forEach({$0.start?()})
        }
        animGroup.completion = { finished in
            animGroup.animations?.forEach({$0.completion?(finished)})
        }
        return animGroup
    }
    func animationWithFade(_ layer: CALayer,
                           fromValue: CGFloat = 0,
                           toValue: CGFloat = 1.0,
                           duration: TimeInterval = 0.4) -> CAAnimation {
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.toValue  = toValue
        fadeAnimation.fromValue  = fromValue
        fadeAnimation.fillMode = .forwards
        fadeAnimation.duration = duration
        fadeAnimation.delegate = self
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.completion = { finished in
            CATransaction.withDisabledActions({
                layer.opacity = Float(toValue)
            })
        }
        return fadeAnimation
    }
    
    

//var kUpY: CGFloat = 115
//var kDownY: CGFloat = 310


    
//    func touchDown() {
//        animateTouchLayer(layer: self.layer, toY:kDownY, baseY:kUpY)
//    }
//
//    func touchUp(){
//        animateTouchLayer(layer: self.layer, toY:kUpY, baseY:kDownY)
//    }
//
//    func animateTouchLayer(layer: CALayer, toY: CGFloat, baseY: CGFloat)  {
//        let fromValue = layer.presentation()?.position ?? .zero
//        let toValue = CGPoint(x:fromValue.x,y:toY)
//
//        layer.position = toValue
//
//        let animation = CABasicAnimation()
//        animation.fromValue = NSValue(cgPoint: fromValue)
//        animation.toValue = NSValue(cgPoint: toValue)
//        animation.duration = CFTimeInterval(2.0 * (toValue.y - fromValue.y) / (toY - baseY))
//        layer.add(animation, forKey:animation.keyPath)
//
//    }
    
    /// Animate points fading
    ///
    /// - Parameters:
    ///   - layers: [OMGradientShapeClipLayer]]
    ///   - delay: TimeInterval
    ///   - duration: TimeInterval
    ///   - fromValue: From value
    ///   - toValue: To value
    ///

    func animateFadingPoints(_ layers: [OMGradientShapeClipLayer],
                               duration: TimeInterval = 2.0,
                               fromValue: Float = 1.0,
                               toValue: Float = 0.5) {
        var delay: TimeInterval = 0.0
        var currentDelay = delay
        let incremenatlDelay = duration / Double(layers.count)
        for point in layers {
            point.opacity = fromValue
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.toValue = toValue
            fadeAnimation.beginTime = CACurrentMediaTime() + currentDelay
            fadeAnimation.duration = duration
            fadeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            fadeAnimation.fillMode = CAMediaTimingFillMode.forwards
            fadeAnimation.isRemovedOnCompletion = false
            point.add(fadeAnimation, forKey: ScrollChartAnimationKeys.renderAnimateFadingPointsKey)
            currentDelay += incremenatlDelay
        }
    }
    
//    func animateLayerOpacy( _ layer: CALayer,
//                            fromValue: CGFloat,
//                            toValue: CGFloat,
//                            duration: TimeInterval = 1.0) {
//        //layer.removeAllAnimations()
//        //let fromValue =  self.contentSize.width /  self.contentOffset.x == 0 ? 1 :  self.contentOffset.x
//        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
//        fadeAnimation.toValue = toValue
//        fadeAnimation.fromValue = fromValue
//        fadeAnimation.beginTime = CACurrentMediaTime() + 0.5
//        fadeAnimation.duration = duration
//        fadeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        fadeAnimation.fillMode = CAMediaTimingFillMode.forwards
//        fadeAnimation.isRemovedOnCompletion = true
//        layer.add(fadeAnimation, forKey: nil)
//    }
    
    /// animateOnRenderLayerSelection
    ///
    /// - Parameters:
    ///   - selectedLayer: OMGradientShapeClipLayer
    ///   - renderIndex: render index
    ///   - duration: TimeInterval [2.0]
    func animateOnRenderLayerSelection(_ selectedLayer: OMGradientShapeClipLayer?,
                                       renderIndex:Int,
                                       duration: TimeInterval = 2.0) {
        var index: Int = 0
        guard let renderLayers = self.renderLayersAndPoints?.renderLayers else { return }
        guard renderLayers.count > 0, let selectedLayer = selectedLayer else {
            return
        }

        index = renderLayers[renderIndex].firstIndex(of: selectedLayer) ?? 0
        
        let count = renderLayers[renderIndex].count
        let pointBegin = renderLayers[renderIndex].takeElements(index)
        let pointEnd   = renderLayers[renderIndex].takeElements(count - index,
                                                                     startAt: index + 1)
        animateFadingPoints(pointBegin.reversed(), duration: duration * 0.5, fromValue: 1.0, toValue: 0.5)
        animateFadingPoints(pointEnd, duration: duration * 0.5, fromValue: 1.0, toValue: 0.5)
    }
    
    //let fromValue =  self.contentSize.width /  self.contentOffset.x == 0 ? 1 :  self.contentOffset.x
     // self.contentOffset.x / self.contentSize.width
    
   
}

