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
import GUILib
import Accelerate

// MARK: - Animations
extension OMScrollableChart {
    
    func performPathAnimation(_ layer: OMGradientShapeClipLayer,
                              _ animation: CAAnimation,
                              _ layerOpacity: CGFloat) {
        if layer.opacity == 0 {
            let anim = animationWithFadeGroup(layer,
                                              fromValue: CGFloat(layer.opacity),
                                              toValue: layerOpacity,
                                              animations: [animation])
            layer.add(anim, forKey: ScrollChartAnimationKeys.renderPathAnimationGroupKey, withCompletion: nil)
        } else {
            
            layer.add(animation, forKey: ScrollChartAnimationKeys.renderPathAnimationKey, withCompletion: nil)
        }
    }
    
    func performPositionAnimation(_ layer: OMGradientShapeClipLayer,
                                          _ animation: CAAnimation,
                                          layerOpacity: CGFloat) {
        let anima = animationWithFadeGroup(layer,
                                           toValue: layerOpacity,
                                           animations: [animation])
        if layer.opacity == 0 {
            layer.add(anima, forKey: ScrollChartAnimationKeys.renderPositionAnimationGroupKey, withCompletion: nil)
        } else {
            layer.add(animation, forKey: ScrollChartAnimationKeys.renderPositionAnimationKey, withCompletion: nil)
        }
    }
    
    func performOpacityAnimation(_ layer: OMGradientShapeClipLayer,
                                         _ animation: CAAnimation) {
        
        layer.add(animation, forKey: ScrollChartAnimationKeys.renderOpacityAnimationKey, withCompletion: nil)
    }
    
    func updateRenderLayersOpacity( for renderIndex: Int, layerOpacity: CGFloat) {
        // Don't delay the opacity
        if renderIndex == Renders.points.rawValue {
            return
        }
        // The render layers must exist
        guard renderLayers.count > 0 else {
            return
        }
        renderLayers[renderIndex].enumerated().forEach { layerIndex, layer  in
            layer.opacity = Float(layerOpacity)
        }
    }
    
    func scrollingProgressAnimatingToPage(_ duration: TimeInterval, page: Int) {
        let delay: TimeInterval = 0.5
        let preTimeOffset: TimeInterval = 1.0
        let duration: TimeInterval = duration + delay - preTimeOffset
        self.layoutIfNeeded()
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: .curveEaseInOut,
                       animations: {
            self.contentOffset.x = self.frame.size.width * CGFloat(1)
        }, completion: { completed in
//            if self.isAnimatePointsClearOpacity &&
//                !self.isAnimatePointsClearOpacityDone {
//                self.updateRenderPointsOpacity()
//                self.isAnimatePointsClearOpacityDone = true
//            }
        })
    }
    func runRideProgress(layerToRide: CALayer?, renderIndex: Int, scrollAnimation: Bool = false) {
        if let anim = self.ridePathAnimation {
            if let layerRide = layerToRide {
                CATransaction.withDisabledActions {
                    layerRide.transform = CATransform3DIdentity
                }
                if scrollAnimation {
                    scrollingProgressAnimatingToPage(anim.duration, page: 1)
                }
                layerRide.add(anim, forKey: "around", withCompletion: {  complete in
                    if let presentationLayer = layerRide.presentation() {
                        CATransaction.withDisabledActions {
                            layerRide.position = presentationLayer.position
                            layerRide.transform = presentationLayer.transform
                        }
                    }
                    self.animationDidEnded(renderIndex: Int(renderIndex), animation: anim)
                    layerRide.removeAnimation(forKey: "around")
                })
            }
        }
    }
    
    func animationDidEnded(renderIndex: Int, animation: CAAnimation) {
        let keyPath = animation.value(forKeyPath: "keyPath") as? String
        if let animationKF = animation as? CAKeyframeAnimation,
           animationKF.path != nil,
           keyPath == "position" {
//            if isAnimatePointsClearOpacity  &&
//                !isAnimatePointsClearOpacityDone {
//                updateRenderPointsOpacity()
//                isAnimatePointsClearOpacityDone = true
//            }
        }
        renderDelegate?.animationDidEnded(chart: self,
                                          renderIndex: renderIndex,
                                          animation: animation)
    }
    
    /// animateRenderLayers
    /// 
    /// - Parameters:
    ///   - renderIndex: render index
    ///   - layerOpacity: opacity
    func animateRenderLayers(_ renderIndex: Int, layerOpacity: CGFloat) {
        guard renderLayers.count > 0 else {
            return
        }
        renderLayers[renderIndex].enumerated().forEach { layerIndex, layer  in
            if let animation = self.renderDelegate?.animateLayers(chart: self,
                                                         renderIndex: renderIndex,
                                                         layerIndex: layerIndex,
                                                         layer: layer) {
                if let animation = animation as? CAAnimationGroup {
                    for anim in animation.animations! {
                        let keyPath = anim.value(forKeyPath: "keyPath") as? String
                        if keyPath == "path" {
                            performPathAnimation(layer, anim, layerOpacity)
                        } else if keyPath == "position" {
                            performPositionAnimation(layer, anim, layerOpacity: layerOpacity)
                        } else if keyPath == "opacity" {
                            performOpacityAnimation(layer, anim)
                        } else {
                            if let keyPath = keyPath {
                                Log.e("Unknown key path \(keyPath) for CAAnimationGroup")
                            }
                        }
                    }
                } else {
                    let keyPath = animation.value(forKeyPath: "keyPath") as? String
                    if keyPath == "path" {
                        performPathAnimation(layer, animation, layerOpacity)
                    } else if keyPath == "position" {
                        performPositionAnimation(layer, animation, layerOpacity: layerOpacity)
                    } else if keyPath == "opacity" {
                        performOpacityAnimation(layer, animation)
                    } else if keyPath == "rideProgress" {
                        runRideProgress(layerToRide: layerToRide,
                                        renderIndex: renderIndex,
                                        scrollAnimation: isScrollAnimation && !isScrollAnimnationDone)
                        isScrollAnimnationDone = true
                    } else {
                        if let keyPath = keyPath {
                            Log.e("Unknown key path \(keyPath) for CAAnimationKey")
                        }
                    }
                }
            }
        }
    }
    func updateRendersOpacity() {
        // Create the points from the discrete data using the renders
        //print("[\(Date().description)] [RND] updating render layer opacity [PKJI]")
        if allDataPointsRender.isEmpty == false {
            if let render = self.renderSource,
               let renderDelegate = renderDelegate, render.numberOfRenders > 0  {
                for renderIndex in 0..<render.numberOfRenders {
                    let opacity = renderDelegate.layerOpacity(chart: self, renderIndex: renderIndex)
                    // layout renders opacity
                    updateRenderLayersOpacity(for: renderIndex, layerOpacity: opacity)
                }
            }
        }
        //print("[\(Date().description)] [RND] visibles \(visibleLayers.count) no visibles \(invisibleLayers.count) [PKJI]")
    }
    
    func updateRenderPointsOpacity( _ toValue: CGFloat = 0, _ duration: TimeInterval = 4.0) {
        guard renderLayers[Renders.points.rawValue].isEmpty == false else {
            return
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        for layer in renderLayers[Renders.points.rawValue] {
            let anim = animationOpacity(layer,
                                        fromValue: CGFloat(layer.opacity),
                                        toValue: toValue)
            layer.add(anim,
                      forKey: ScrollChartAnimationKeys.renderOpacityClearAnimationKey)
        }
        CATransaction.commit()
    }
}
