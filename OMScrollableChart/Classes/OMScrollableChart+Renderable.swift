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

var animationTimingTable: [AnimationTiming] = [
    .oneShot,
    .oneShot,
    .oneShot,
    .none,
    .none,
    .none,
    .none
]

extension OMScrollableChart: RenderableDelegateProtocol, RenderableProtocol {
//    func animateLayers(chart: OMScrollableChart,
//                       renderIndex: Int,
//                       layerIndex: Int,
//                       layer: OMGradientShapeClipLayer) -> CAAnimation? {
//        switch Renders(rawValue: renderIndex) {
//        case .points, .selectedPoint, .currentPoint, .segments:
//            return nil
//        case .polyline:
//            guard let polylinePath = chart.polylinePath,
//                    let layerToRide = chart.renderSelectedPointsLayer else {
//                return nil
//            }
//            // Ride the selected point along the polyline path
//            return chart.animateLayerPathRideToPoint( polylinePath,
//                                                      layerToRide: layerToRide,
//                                                      pointIndex: chart.numberOfSections,
//                                                      duration: 10)
//            
//        case .bar1:
//            let pathStart = pathsToAnimate[renderIndex - 3][layerIndex]
//            return chart.animateLayerPath( layer,
//                                           pathStart: pathStart,
//                                           pathEnd: UIBezierPath( cgPath: layer.path!))
//        case .bar2:
//            let pathStart = pathsToAnimate[renderIndex - 3][layerIndex]
//            return chart.animateLayerPath( layer,
//                                           pathStart: pathStart,
//                                           pathEnd: UIBezierPath( cgPath: layer.path!) )
//            
//        default:
//            return nil
//        }
//    }
    var numberOfRenders: Int {
        return RendersBase
    }
//    func dataLayers(chart: OMScrollableChart, renderIndex: Int, section: Int, points: [CGPoint]) -> [OMGradientShapeClipLayer] {
//        switch Renders(rawValue:  renderIndex) {
//        case .bar1:
//            let layers =  chart.createRectangleLayers(points, columnIndex: 1, count: 6,
//                                                      color: .black)
//#if DEBUG
//            layers.forEach({$0.name = "bar income"})  //debug
//#endif
//            self.pathsToAnimate.insert(
//                chart.createInverseRectanglePaths(points, columnIndex: 1, count: 6),
//                at: 0)
//            return layers
//        case .bar2:
//            
//            let layers =  chart.createRectangleLayers(points, columnIndex: 4, count: 6,
//                                                      color: .green)
//#if DEBUG
//            layers.forEach({$0.name = "bar outcome"})  //debug
//#endif
//            
//            self.pathsToAnimate.insert(
//                chart.createInverseRectanglePaths(points, columnIndex: 4, count: 6),
//                at: 1)
//            return layers
//            
//        default:
//            return []
//        }
//    }

    func queryAnimation(chart: OMScrollableChart, renderIndex: Int) -> AnimationTiming {
        return animationTimingTable[renderIndex]
    }

    func didSelectDataIndex(chart: OMScrollableChart, renderIndex: Int, dataIndex: Int, layer: CALayer) {
        switch Renders(rawValue: renderIndex) {
        case .polyline:
            chart.renderLayersAndPoints?.renderLayers[Renders.selectedPoint.rawValue].first?.position =  layer.position
        case .points:
            break
        case .segments:
            break
        case .selectedPoint:
            break
        case .currentPoint:
            break
        case .bar1:
            break
        case .bar2:
            break
        case .none:
            break
        }
    }
    func animationDidEnded(chart: OMScrollableChart, renderIndex: Int, animation: CAAnimation) {
        switch Renders(rawValue: renderIndex) {
        case .polyline:
            break
        case .points:
            break
        case .segments:
            animationTimingTable[renderIndex] = .none
        case .selectedPoint:
            break
        case .currentPoint:
            break
        case .bar1:
            break
        case .bar2:
            break
        case .none:
            break
        }
    }
    func layerOpacity(chart: OMScrollableChart, renderIndex: Int) -> CGFloat {
        switch renderIndex {
        case 0: return 1
        case 1: return 1
        case 2: return 1
        case 3: return 1
        case 4: return 1
        case 5: return 0
        case 6: return 0
        default: return 0
        }
    }
}
