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


extension Array where Element: (Comparable & SignedNumeric) {
    func nearest(to value: Element) -> (offset: Int, element: Element)? {
        self.enumerated().min(by: {
            abs($0.element - value) < abs($1.element - value)
        })
    }
}

// MARK: - OMScrollableChartTouches
extension OMScrollableChart: TouchesProtocol {
    
    func onTouchesMoved(_ touches: Set<UITouch>) {
        let location: CGPoint = locationFromTouchInContentView(touches)
        self.tooltip?.moveTooltip(location)
    }
    func onTouchesEnded(_ touches: Set<UITouch>) {
        let location: CGPoint = locationFromTouchInContentView(touches)
        self.tooltip?.hideTooltip(location)
    }
    
//    func onPointSelected(_ selectedLayer: OMGradientShapeClipLayer, _ location: CGPoint, _ renderIndex: Int) {
//        if isAnimateLineSelection {
//            if let path = self.polylinePath {
//                let animatiom = self.animateLineSelection( with: selectedLayer, path)
//                let duration = 10.0
//                CATransaction.begin()
//                CATransaction.setAnimationDuration(duration)
//                selectedLayer.add(animatiom,
//                          forKey: ScrollChartAnimationKeys.renderAnimateLineSelectionKey)
//                
//                CATransaction.commit()
//            }
//        }
//        selectRenderLayerWithAnimation(selectedLayer,
//                                       selectedPoint: location,
//                                       renderIndex: renderIndex)
//    }
    
    ///
    /// renderForLayer
    ///
    /// - Parameter layer: CALayer
    /// - Returns: Renders?
    ///
    func renderForLayer(_ layer: CALayer) -> Renders? {
        guard let renderLayers = self.renderLayersAndPoints?.renderLayers else { return nil }
        for renderIndex in 0..<renderLayers.count {
            if renderLayers[renderIndex].filter({$0 == layer}).count > 0 {
                return Renders(rawValue: renderIndex)
            }
        }
        return nil
    }
    
    ///
    /// Select Segment Layer And Border
    ///
    /// - Parameter offset: Int
    ///
    func selectSegmentLayerAndBorder(_ offset: Int) {
        guard let renderLayers = self.renderLayersAndPoints?.renderLayers else { return }
        let halfIndex = renderLayers[Renders.segments.rawValue].count / 2
        let segmentLayer = renderLayers[Renders.segments.rawValue][offset]
        let segmentLayerBorder = renderLayers[Renders.segments.rawValue][offset+halfIndex]
        self.selectRenderLayer(segmentLayer, renderIndex: Renders.segments.rawValue)
        self.selectRenderLayer(segmentLayerBorder, renderIndex: Renders.segments.rawValue)
        self.selectedSegmentRenderLayer = segmentLayer
    }
    
    ///
    /// onPointsLayersTouch
    ///
    /// - Parameters:
    ///   - location: CGPoint
    ///   - layer: layer OMGradientShapeClipLayer
    ///
    func onPointsLayersTouch(_ location: CGPoint, _ layer: OMGradientShapeClipLayer) {
        Log.v("Simple point touches")
        // Animate the selected point layer
        layer.add(self.growAnimation, forKey: "GrowAnimation")
        // Save the selected point layer
        self.selectedPointRenderLayer = layer
        guard let renderLayers = self.renderLayersAndPoints?.renderLayers else { return }
        // Calculate the segment layer next to the selected Point
        let mapped = renderLayers[Renders.segments.rawValue].map {$0.frame.origin.x - location.x}
        
        guard let nearest = mapped.nearest(to: 0) else {
            return
        }
        
        selectSegmentLayerAndBorder(nearest.offset)
        
        self.selectRenderLayerWithAnimation(layer,
                                            selectedPoint: location,
                                            renderIndex: Renders.points.rawValue)
    }
    
    ///
    /// onPolylineLayersTouch
    ///
    /// - Parameters:
    ///   - location: CGPoint
    ///   - layer: layer OMGradientShapeClipLayer
    ///
    func onPolylineLayersTouch(_ location: CGPoint,_ layer: OMGradientShapeClipLayer) {
        Log.v("Polyline touches")
        guard let selectedRenderLayer = self.selectedSegmentRenderLayer as? OMGradientShapeClipLayer else {
            return
        }
        if renderForLayer(selectedRenderLayer) == .segments {
            self.deselectRenderLayer(renderIndex: Renders.segments.rawValue)
            guard let hitTestLayer  = hitTestAsLayer(location) as? OMGradientShapeClipLayer else {
                return
            }
            if renderForLayer(hitTestLayer) == .segments {
                self.selectRenderLayer(hitTestLayer, renderIndex: Renders.segments.rawValue)
            }
        }
    }
    ///
    /// onSegmentsLayersTouch
    ///
    /// - Parameters:
    ///   - location: CGPoint
    ///   - layer: layer OMGradientShapeClipLayer
    ///
    func onSegmentsLayersTouch(_ location: CGPoint,_ layer: OMGradientShapeClipLayer) {
        Log.v("Segment touches")
        self.selectRenderLayer(layer, renderIndex: Renders.segments.rawValue)
        self.selectedSegmentRenderLayer = layer
    }
    ///
    /// onCurrentPointLayersTouch
    ///
    /// - Parameters:
    ///   - location: CGPoint
    ///   - layer: layer OMGradientShapeClipLayer
    ///
    func onCurrentPointLayersTouch(_ location: CGPoint,_ layer: OMGradientShapeClipLayer) {
        Log.v("Current point touches")
        // Animate the selected point layer
        layer.add(self.growAnimation, forKey: "GrowAnimation")
    }
    ///
    /// onSelectedPointLayersTouch
    ///
    /// - Parameters:
    ///   - location: CGPoint
    ///   - layer: layer OMGradientShapeClipLayer
    ///
    func onSelectedPointLayersTouch(_ location: CGPoint,_ layer: OMGradientShapeClipLayer) {
        Log.v("Selected point touches")
        // Animate the selected point layer
        layer.add(self.growAnimation, forKey: "GrowAnimation")
    }
    ///
    /// onTouchesBegan
    ///
    /// - Parameters:
    ///   - touches: Set<UITouch>
    ///
    func onTouchesBegan(_ touches: Set<UITouch>) {
        let location: CGPoint = locationFromTouchInContentView(touches)
        guard let hitTestLayer  = hitTestAsLayer(location) as? OMGradientShapeClipLayer else {
            return
        }
        guard let render = renderForLayer(hitTestLayer) else {
            return
        }
        switch render {
            case .points:
                onPointsLayersTouch(location, hitTestLayer)
            case .polyline:
                onPolylineLayersTouch(location, hitTestLayer)
            case .segments:
                onSegmentsLayersTouch(location, hitTestLayer)
            case .currentPoint:
                onCurrentPointLayersTouch(location, hitTestLayer)
            case .selectedPoint:
                onSelectedPointLayersTouch(location, hitTestLayer)
            default:
            break
        }
        
//        if self.currentSelectedSegment != -1 {
//            self.deselectRenderLayer(renderIndex: Renders.points.rawValue)
//            self.currentSelectedSegment = -1
//        }
//        var unselectAll = true
//        if isSelectedRenderLayersSegment == false {
//            self.isSelectedRenderLayersSegment = true
//            self.selectRenderLayer(layer, renderIndex: Renders.segments.rawValue)
//            unselectAll = false
//        }
//        if unselectAll && isSelectedRenderLayersSegment {
//            self.deselectRenderLayer(renderIndex: Renders.segments.rawValue)
//            self.isSelectedRenderLayersSegment = false
//        }
        
//        if let hitTestLayer = hitTestLayer {
//            
//            let isPointsLayer = renderLayers[Renders.points.rawValue].filter {$0 == hitTestLayer}.count > 0
//            let isSegmentLayer = renderLayers[Renders.segments.rawValue].filter {$0 == hitTestLayer}.count > 0
//            
////            let isCurrentPointLayer = renderLayers[Renders.currentPoint.rawValue].filter {$0 == hitTestLayer}.count > 0
////            let isSelectedPointLayer = renderLayers[Renders.selectedPoint.rawValue].filter {$0 == hitTestLayer}.count > 0
//            
//            // Unselected the segment layers
//            
//            if isSegmentLayer {
//                if self.currentSelectedSegment != -1 {
//                    self.deselectRenderLayer(renderIndex: Renders.points.rawValue)
//                    self.currentSelectedSegment = -1
//                }
//                var unselectAll = true
//                if isSelectedRenderLayersSegment == false {
//                    self.isSelectedRenderLayersSegment = true
//                    self.selectRenderLayer(hitTestLayer, renderIndex: Renders.segments.rawValue)
//                    unselectAll = false
//                }
//                if unselectAll && isSelectedRenderLayersSegment {
//                    self.deselectRenderLayer(renderIndex: Renders.segments.rawValue)
//                    self.isSelectedRenderLayersSegment = false
//                }
//            } else if isPointsLayer {
//                
//                hitTestLayer.add(keyFrameGrowAnimation(duration: 0.5),
//                                   forKey: "keyFrameGrowAnimation")
//                
//                let mapped = renderLayers[Renders.segments.rawValue].map {$0.frame.origin.x - location.x}
//                guard let index = mapped.lastIndex(where: {$0 < 0}) else {
//                    return
//                }
//                var currentIndex = index
//                if currentIndex == currentSelectedSegment {
//                    currentIndex += 1
//                }
//                self.currentSelectedSegment = currentIndex
//                let segmentLayer = renderLayers[Renders.segments.rawValue][currentIndex]
//                self.selectRenderLayer(segmentLayer, renderIndex: Renders.segments.rawValue)
//                
//                
//          
//// Animatiion movieng the seg,ent
////                let segmentLayerPrev = renderLayers[Renders.segments.rawValue][index-1]
////                if let prevPath = segmentLayerPrev.path, let currentPath = segmentLayer.path {
////                    let animatiom = self.animateLayerPath( hitTestLayer,
////                                                           pathStart: UIBezierPath(cgPath: prevPath),
////                                                           pathEnd: UIBezierPath(cgPath: currentPath))
////                    CATransaction.begin()
////                    CATransaction.setAnimationDuration(0.1)
////                    segmentLayer.add(animatiom,
////                                     forKey: ScrollChartAnimationKeys.renderAnimateLineSelectionKey)
////    
////                    CATransaction.commit()
////                }
//        
//                
////                self.animateOnRenderLayerSelection(hitTestLayer,
////                                                   renderIndex: Renders.points.rawValue,
////                                                   duration: 2.0)
//            } else {
//                if isSelectedRenderLayersSegment {
//                    self.deselectRenderLayer(renderIndex: Renders.segments.rawValue)
//                    self.isSelectedRenderLayersSegment = false
//                }
//            }
//        }
//        
////        if let hitTestLayer = hitTestLayer {
////            var isSelected: Bool = false
////            // skip polyline layer, start in points
////            for renderIndex in 0..<renderLayers.count {
////                // Get the point more near
////                if let selectedLayer = locationToLayer(location, renderIndex: renderIndex) {
////                    if hitTestLayer == selectedLayer {
////                        selectRenderLayerWithAnimation(selectedLayer,
////                                                       selectedPoint: location,
////                                                       renderIndex: renderIndex)
//////                        onPointSelected(selectedLayer, location, renderIndex)
////                        isSelected = true
////                    }
////                }
////            }
////            // Not point selected
////            if !isSelected {
////                // get the most near point
////                 if  let mostNearLayerPoint = locationToLayer(location,
////                                                              renderIndex: Renders.points.rawValue) {
////
////                    selectRenderLayerWithAnimation(mostNearLayerPoint,
////                                                   selectedPoint: location,
////                                                   animation: true,
////                                                   renderIndex: Renders.points.rawValue)
////                }
////            }
////        }
    }
}
