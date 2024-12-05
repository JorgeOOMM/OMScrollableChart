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

// MARK: - OMScrollableChartTouches
extension OMScrollableChart: TouchesProtocol {
    func onTouchesMoved(_ touches: Set<UITouch>) {
        let location: CGPoint = locationFromTouchInContentView(touches)
        //updateLineSelectionLayer(location)
        tooltip.moveTooltip(location)
    }
    func onTouchesEnded(_ touches: Set<UITouch>) {
        let location: CGPoint = locationFromTouchInContentView(touches)
        tooltip.hideTooltip(location)
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
    
    func onTouchesBegan(_ touches: Set<UITouch>) {
        let location: CGPoint = locationFromTouchInContentView(touches)
        //updateLineSelectionLayer(location)
        let hitTestLayer: CALayer? = hitTestAsLayer(location) as? CAShapeLayer
        if let hitTestLayer = hitTestLayer {
            var isSelected: Bool = false
            // skip polyline layer, start in points
            for renderIndex in Renders.points.rawValue..<renderLayers.count {
                // Get the point more near
                if let selectedLayer = locationToLayer(location, renderIndex: renderIndex) {
                    if hitTestLayer == selectedLayer {
                        selectRenderLayerWithAnimation(selectedLayer,
                                                       selectedPoint: location,
                                                       renderIndex: renderIndex)
//                        onPointSelected(selectedLayer, location, renderIndex)
                        isSelected = true
                    }
                }
            }
            // Not point selected
            if !isSelected {
                // get the most near point
                 if  let mostNearLayerPoint = locationToLayer(location,
                                                              renderIndex: Renders.points.rawValue) {

                    selectRenderLayerWithAnimation(mostNearLayerPoint,
                                                   selectedPoint: location,
                                                   animation: true,
                                                   renderIndex: Renders.points.rawValue)
                }
            }
        }
    }
}
