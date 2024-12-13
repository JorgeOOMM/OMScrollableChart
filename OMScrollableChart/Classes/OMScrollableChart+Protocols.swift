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

protocol TouchesProtocol {
    func onTouchesBegan(_ touches: Set<UITouch>)
    func onTouchesMoved(_ touches: Set<UITouch>)
    func onTouchesEnded(_ touches: Set<UITouch>)
}

protocol RenderLocationProtocol {
    func indexForPoint(_ point: CGPoint, renderIndex: Int) -> Int?
    func dataStringFromPoint(_ point: CGPoint, renderIndex: Int) -> String?
    func dataFromPoint(_ point: CGPoint, renderIndex: Int) -> Float?
    func dataIndexFromPoint(_ point: CGPoint, renderIndex: Int) -> Int?
    func dataIndexFromLayers(_ point: CGPoint, renderIndex: Int) -> Int?
}

protocol ChartProtocol {
    associatedtype ChartData
    var discreteData: [ChartData?] {get set}
    func updateBasicSourceData() -> Bool
}

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
    case polyline
    case points
    case segments
    case selectedPoint
    case currentPoint
    case bar1
    case bar2
}

//  public renders base index
let RendersBase = Renders.bar2.rawValue + 1

public enum AnimationTiming: Hashable {
    case none
    case repeatn(Int)
    case infinite
    case oneShot
}

protocol DataSourceProtocol: AnyObject {
    func dataPoints(chart: OMScrollableChart, renderIndex: Int, section: Int) -> [Float]
    func footerSectionsText(chart: OMScrollableChart) -> [String]?
    func dataPointTootipText(chart: OMScrollableChart, renderIndex: Int, dataIndex: Int, section: Int) -> String?
    func dataOfRender(chart: OMScrollableChart, renderIndex: Int) -> RenderType
    func dataSectionForIndex(chart: OMScrollableChart, dataIndex: Int, section: Int) -> String?
    func numberOfSectionsPerPage(chart: OMScrollableChart) -> Int
}
protocol RenderableDelegateProtocol: AnyObject {
    func layerOpacity(chart: OMScrollableChart, renderIndex: Int) -> CGFloat
    func queryAnimation(chart: OMScrollableChart, renderIndex: Int) -> AnimationTiming
    func animationDidEnded(chart: OMScrollableChart,  renderIndex: Int, animation: CAAnimation)
    func didSelectDataIndex(chart: OMScrollableChart, renderIndex: Int, dataIndex: Int, layer: CALayer)
    func dataLayers(chart: OMScrollableChart, renderIndex: Int, section: Int, points: [CGPoint]) -> [OMGradientShapeClipLayer]
    func animateLayers(chart: OMScrollableChart, renderIndex: Int, layerIndex: Int ,layer: OMGradientShapeClipLayer) -> CAAnimation?
}
protocol RenderableProtocol: AnyObject {
    var numberOfRenders: Int {get}
}

extension RenderableProtocol {
    // Default renders, polyline and points
    var numberOfRenders: Int {
        return 2
    }
}
