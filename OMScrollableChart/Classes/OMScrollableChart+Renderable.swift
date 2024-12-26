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

extension UIColor {
    var colorMap: [UIColor] {
        return [self.lighterColor(percent: 0.0),
                self.lighterColor(percent: 0.1),
                self.lighterColor(percent: 0.2),
                self.lighterColor(percent: 0.3),
                self.lighterColor(percent: 0.4),
                self.darkerColor(percent: 0.4),
                self.darkerColor(percent: 0.3),
                self.darkerColor(percent: 0.2),
                self.darkerColor(percent: 0.1),
                self.darkerColor(percent: 0.0)]
    }
}


let layersOnTopBaseZPosition: CGFloat = 10000
let layersUnderTopBaseZPosition: CGFloat = 1000
let layersUnderUnderBaseZPosition: CGFloat = 100


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
    var numberOfRenders: Int {
        return RendersBase
    }
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

//
// Query the data layers to the delegate
//
extension OMScrollableChart {

    func regressBondsSize(_ renderIndex: Int) -> CGSize {
        let size = contentView.bounds.size
        let numOfPoints = CGFloat(self.renderDataPoints[renderIndex].count)
        let regressWidth = (self.sectionWidth * CGFloat(self.numberOfRegressValues))
        let width = numOfPoints * self.sectionWidth + regressWidth
        return  CGSize(width: width,
                       height: size.height)
    }
    
    func discreteBondsSize(_ renderIndex: Int) -> CGSize {
        let size = contentView.bounds.size
        return CGSize(width: CGFloat(self.renderDataPoints[renderIndex].count) * self.sectionWidth, height: size.height)
    }
    
    /// renderLayers
    ///
    /// - Parameters:
    ///   - renderIndex: render index
    ///   - renderAs: RenderData
    func renderLayers(_ renderIndex: Int, renderAs: RenderType) {
        let currentRenderData = renderDataPoints[renderIndex]
        switch renderAs {
        case .simplified(let value):
            self.renderLayersAndPoints?.makeSimplified(currentRenderData, renderIndex, discreteBondsSize(renderIndex), value)
        case .averaged(let value):
            self.renderLayersAndPoints?.makeAverage(currentRenderData, renderIndex, discreteBondsSize(renderIndex), value)
        case .discrete:
            self.renderLayersAndPoints?.makeDiscrete(currentRenderData, renderIndex, discreteBondsSize(renderIndex))
        case .linregress(let value):
            self.renderLayersAndPoints?.makeLinregress(currentRenderData, renderIndex, regressBondsSize(renderIndex), value)
        }
        self.renderType.insert(renderAs, at: renderIndex)
    }
}
