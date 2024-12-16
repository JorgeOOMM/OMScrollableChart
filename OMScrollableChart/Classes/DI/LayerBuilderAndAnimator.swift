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

class LayerBuilderAndAnimator: LayerBuilderAndAnimatorProtocol {
    var animatedPaths = [[UIBezierPath]]()
    var renderLayersAndPoints:RenderLayersAndPointsProtocol
    var layersAnimator: LayersAnimatorProtocol
    required init(renderLayersAndPoints: RenderLayersAndPointsProtocol, layersAnimator: LayersAnimatorProtocol) {
        self.renderLayersAndPoints = renderLayersAndPoints
        self.layersAnimator = layersAnimator
    }
    func animateLayers(renderIndex: Int,
                       layerIndex: Int,
                       layer: OMGradientShapeClipLayer) -> CAAnimation? {
        switch Renders(rawValue: renderIndex) {
        case .points, .selectedPoint, .currentPoint, .segments:
            return nil
        case .polyline:
            guard let polylinePath = renderLayersAndPoints.polylinePath,
                  let layerToRide = renderLayersAndPoints.renderLayers[Renders.selectedPoint.rawValue].first else {
                return nil
            }
            // Ride the selected point along the polyline path
            return self.layersAnimator.animateLayerPathRideToPoint( polylinePath,
                                                layerToRide: layerToRide,
                                                percent: 1.0,
                                                duration: 10)
            
        case .bar1:
            let pathStart = self.animatedPaths[renderIndex - 3][layerIndex]
            return self.layersAnimator.animateLayerPath( layer,
                                     pathStart: pathStart,
                                     pathEnd: UIBezierPath( cgPath: layer.path!), duration: 0.5)
        case .bar2:
            let pathStart = self.animatedPaths[renderIndex - 3][layerIndex]
            return self.layersAnimator.animateLayerPath( layer,
                                     pathStart: pathStart,
                                                         pathEnd: UIBezierPath( cgPath: layer.path!), duration: 0.5)
            
        default:
            return nil
        }
    }
    func buildLayers(for renderIndex: Int, section: Int, points: [CGPoint]) -> [OMGradientShapeClipLayer] {
        switch Renders(rawValue:  renderIndex) {
        case .bar1:
            let layers =  self.renderLayersAndPoints.createRectangleLayers(points, columnIndex: 1, count: 6,
                                                      color: .black)
#if DEBUG
            layers.forEach({$0.name = "bar income"})  //debug
#endif
            self.animatedPaths.insert(
                self.renderLayersAndPoints.createInverseRectanglePaths(points, columnIndex: 1, count: 6),
                at: 0)
            return layers
        case .bar2:
            
            let layers =  self.renderLayersAndPoints.createRectangleLayers(points, columnIndex: 4, count: 6,
                                                      color: .green)
#if DEBUG
            layers.forEach({$0.name = "bar outcome"})  //debug
#endif
            
            self.animatedPaths.insert(
                self.renderLayersAndPoints.createInverseRectanglePaths(points, columnIndex: 4, count: 6),
                at: 1)
            return layers
            
        default:
            return []
        }
    }
}
