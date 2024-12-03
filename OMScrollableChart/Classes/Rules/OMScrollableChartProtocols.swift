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

protocol OMScrollableChartTouches {
    func onTouchesBegan(_ touches: Set<UITouch>)
    func onTouchesMoved(_ touches: Set<UITouch>)
    func onTouchesEnded(_ touches: Set<UITouch>)
}

extension OMScrollableChart {
    public enum RenderType: Equatable{
        case discrete
        case averaged(Int)
        case simplified(CGFloat)
        case linregress(Int)
        var  isAveraged: Bool {
            switch self {
            case .averaged(_): return true
            default: return false
            }
        }
    }
    // MARK: Default renders
    enum Renders: Int {
        case points
        case polyline
        case segments
        case selectedPoint
        case currentPoint
        case bar1
        case bar2
        case base          //  public renders base index
    }
}

protocol ChartProtocol {
    associatedtype ChartData
    var discreteData: [ChartData?] {get set}
    func updateDataSourceData() -> Bool
}

public enum AnimationTiming: Hashable {
    case none
    case repeatn(Int)
    case infinite
    case oneShot
}

protocol OMScrollableChartDataSource: AnyObject {
    func dataPoints(chart: OMScrollableChart, renderIndex: Int, section: Int) -> [Float]
    func numberOfPages(chart: OMScrollableChart) -> CGFloat
    func dataLayers(chart: OMScrollableChart, renderIndex: Int, section: Int, points: [CGPoint]) -> [OMGradientShapeClipLayer]
    func footerSectionsText(chart: OMScrollableChart) -> [String]?
    func dataPointTootipText(chart: OMScrollableChart, renderIndex: Int, dataIndex: Int, section: Int) -> String?
    func dataOfRender(chart: OMScrollableChart, renderIndex: Int) -> OMScrollableChart.RenderType
    func dataSectionForIndex(chart: OMScrollableChart, dataIndex: Int, section: Int) -> String?
    func numberOfSectionsPerPage(chart: OMScrollableChart) -> Int
    func layerOpacity(chart: OMScrollableChart, renderIndex: Int) -> CGFloat
    func queryAnimation(chart: OMScrollableChart, renderIndex: Int) -> AnimationTiming
    func animateLayers(chart: OMScrollableChart, renderIndex: Int, layerIndex: Int ,layer: OMGradientShapeClipLayer) -> CAAnimation?
    
    
}
protocol OMScrollableChartRenderableDelegateProtocol: AnyObject {
    func animationDidEnded(chart: OMScrollableChart,  renderIndex: Int, animation: CAAnimation)
    func didSelectDataIndex(chart: OMScrollableChart, renderIndex: Int, dataIndex: Int, layer: CALayer)
}
protocol OMScrollableChartRenderableProtocol: AnyObject {
    var numberOfRenders: Int {get}
}
extension OMScrollableChartRenderableProtocol {
    // Default renders, polyline and points
    var numberOfRenders: Int {
        return 2
    }
}
