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
//  OMScrollableChart+Selection.swift
//
//  Created by Jorge Ouahbi on 22/08/2020.
//  Copyright © 2020 dsp. All rights reserved.
//

import UIKit
import GUILib

extension OMScrollableChart {
    /// selectNearestRenderLayer
    ///
    /// - Parameters:
    ///   - point: point
    ///   - renderIndex: render index
    func selectNearestRenderLayer( from point: CGPoint, renderIndex: Int) {
        /// Select the last point if the render is not hidden.
        guard let lastPoint = locationToLayer(point,
                                              renderIndex: renderIndex,
                                              mostNearLayer: true) else {
            return
        }
        selectRenderLayerWithAnimation(lastPoint,
                                       selectedPoint: point,
                                       renderIndex: renderIndex)
    }
    /// selectRenderLayer
    ///
    /// - Parameters:
    ///   - layer: layer
    ///   - renderIndex: Int
    func selectRenderLayer(_ layer: OMGradientShapeClipLayer, renderIndex: Int) {
        guard let renderLayers = self.renderLayersAndPoints?.renderLayers else { return }
        renderLayers[renderIndex].filter { $0 != layer && $0.path != layer.path }.forEach { (layer: OMGradientShapeClipLayer) in
            layer.gardientColor = ScrollChartTheme.unselectedColor
            layer.opacity      = ScrollChartTheme.unselectedOpacy
        }
        layer.gardientColor = ScrollChartTheme.selectedColor
        layer.opacity   = ScrollChartTheme.selectedOpacy
    }
    
    func deselectRenderLayer(renderIndex: Int) {
        guard let renderLayers = self.renderLayersAndPoints?.renderLayers else { return }
        renderLayers[renderIndex].forEach { (layer: OMGradientShapeClipLayer) in
            layer.gardientColor = ScrollChartTheme.selectedColor
            layer.opacity   = ScrollChartTheme.selectedOpacy
        }
    }
    /// locationToLayer
    ///
    /// - Parameters:
    ///   - location: CGPoint
    ///   - renderIndex: renderIndex
    ///   - mostNearLayer: Bool
    /// - Returns: OMGradientShapeClipLayer
    func locationToLayer( _ location: CGPoint, renderIndex: Int, mostNearLayer: Bool = true) -> OMGradientShapeClipLayer? {
        guard let renderLayers = self.renderLayersAndPoints?.renderLayers else { return nil }
        let mapped = renderLayers[renderIndex].map {
            return $0.frame.origin.distance(from: location)
        }
        if mostNearLayer {
            guard let index = mapped.indexOfMin else {
                return nil
            }
            return renderLayers[renderIndex][index]
        } else {
            guard let index = mapped.indexOfMax else {
                return nil
            }
            return renderLayers[renderIndex][index]
        }
    }
    /// hitTestAsLayer
    ///
    /// - Parameter location: Point location
    /// - Returns: CALayer
    func hitTestAsLayer( _ location: CGPoint) -> CALayer? {
        if let layer = contentView.layer.hitTest(location) { // If you hit a layer and if its a Shapelayer
            return layer
        }
        return nil
    }
    /// didSelectedRenderLayerIndex
    ///
    /// - Parameters:
    ///   - layer: layer
    ///   - renderIndex: Int
    ///   - dataIndex: Int
    func didSelectedRenderLayerIndex(layer: CALayer, renderIndex: Int, dataIndex: Int) {
        // lets animate the footer rule
        if let footer = footerRule as? OMScrollableChartRuleFooter,
           let views = footer.views {
            if dataIndex < views.count {
                views[dataIndex].shakeGrow(duration: 1.0)
            } else {
                print("Section index is out of bounds", dataIndex, views.count)
            }
        }
        renderDelegate?.didSelectDataIndex(chart: self,
                                           renderIndex: renderIndex,
                                           dataIndex: dataIndex,
                                           layer: layer)
    }
    /// selectRenderLayerWithAnimation
    ///
    /// - Parameters:
    ///   - layerPoint: OMGradientShapeClipLayer
    ///   - selectedPoint: CGPoint
    ///   - animation: Bool
    ///   - renderIndex: Int
    func selectRenderLayerWithAnimation(_ layerPoint: OMGradientShapeClipLayer,
                                        selectedPoint: CGPoint,
                                        animation: Bool = false,
                                        renderIndex: Int,
                                        duration: TimeInterval = 0.5) {
        
        CATransaction.lock()
        CATransaction.setAnimationDuration(duration)
        CATransaction.begin()
        

        
        if self.animatePointLayers {
            self.animateOnRenderLayerSelection(layerPoint,
                                               renderIndex: renderIndex,
                                               duration: duration)
        }
        var tooltipPosition = CGPoint.zero
        var tooltipPositionFix = CGPoint.zero
        if animation {
            tooltipPositionFix = layerPoint.position
        }
        // Get the selection data index
        if let dataIndex = dataIndexFromPoint(layerPoint.position,
                                              renderIndex: renderIndex) {
            
            print("Selected item: \(dataIndex)")
            //self.polylinePath?.cgPath.elementsPoints()
            // notify the selection
            didSelectedRenderLayerIndex(layer: layerPoint,
                                        renderIndex: renderIndex,
                                        dataIndex: dataIndex)
            // grab the tool tip text
            let tooltipText = dataSource?.dataPointTootipText(chart: self,
                                                              renderIndex: renderIndex,
                                                              dataIndex: dataIndex,
                                                              section: 0)
            // grab the section
            let dataSection = dataSource?.dataSectionForIndex(chart: self,
                                                              dataIndex: dataIndex,
                                                              section: 0) ?? ""
            tooltipPosition = CGPoint(x: layerPoint.position.x,
                                      y: selectedPoint.y)
            
            if let tooltipText = tooltipText {                      // the dataSource was priority
                tooltip.string = "\(dataSection) \(tooltipText)"
                tooltip.displayTooltip(tooltipPosition, duration: duration)
            } else {
                let amount: Double = Double(renderDataPoints[renderIndex][dataIndex])
                // then calculate manually
                if let dataString = currencyFormatter.string(from: NSNumber(value: amount)) {
                    tooltip.string = "\(dataSection) \(dataString)"
                } else if let string = dataStringFromPoint(layerPoint.position, renderIndex: renderIndex) {
                    tooltip.string = "\(dataSection) \(string)"
                } else {
                    print("FIXME: unexpected render | data \(renderIndex) | \(dataIndex)")
                }
                tooltip.displayTooltip(tooltipPosition, duration: duration)
            }
        }
        if animation {
            let distance = tooltipPositionFix.distance(tooltipPosition)
            let factor: TimeInterval = TimeInterval(1 / (self.contentView.bounds.height / distance))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tooltip.moveTooltip(tooltipPositionFix,
                                         duration: factor * duration)
            }
        }
        CATransaction.commit()
        CATransaction.unlock()
    }
    /// locationFromTouchInContentView
    ///
    /// - Parameter touches: Set<UITouch>
    /// - Returns: CGPoint
    func locationFromTouchInContentView(_ touches: Set<UITouch>) -> CGPoint {
        if let touch = touches.first {
            return touch.location(in: self.contentView)
        }
        return .zero
    }
}
