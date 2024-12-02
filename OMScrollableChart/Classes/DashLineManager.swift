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

public class DashLineManager {
    
    func removeVerticalLineLayers() {
        dashVerticalLineLayers.forEach({$0.removeFromSuperlayer()})
        dashVerticalLineLayers.removeAll()
    }
    
    var dashVerticalLineLayers = [CAShapeLayer]()
    var contentView: UIView
    init(contentView: UIView) {
        self.contentView = contentView
    }
    
    /// addDashLineLayer
    ///
    /// - Parameters:
    ///   - point: CGPoint
    ///   - endPoint: CGPoint
    ///   - stroke: UIColor
    ///   - lineWidth: CGFloat
    ///   - pattern: [NSNumber]?
    
    func lineForRuleMark(point: CGPoint,
                                      endPoint: CGPoint,
                                      stroke: UIColor? = nil,
                                      lineWidth: CGFloat? = nil,
                                      pattern: [NSNumber]? = nil)
    {
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = stroke?.cgColor ?? dashLineColor
        lineLayer.lineWidth = lineWidth ?? dashLineWidth
        lineLayer.lineDashPattern = pattern ?? dashPattern as [NSNumber]
        let path = CGMutablePath()
        path.addLines(between: [point, endPoint])
        lineLayer.path = path
        lineLayer.name = "Rule mark dashline"
        dashVerticalLineLayers.append(lineLayer)
        contentView.layer.addSublayer(lineLayer)
    }
    
    var dashPattern: [CGFloat] = [1, 2] {
        didSet {
            dashVerticalLineLayers.forEach { ($0).lineDashPattern = dashPattern.map { NSNumber(value: Float($0)) }}
        }
    }
    
    var dashLineWidth: CGFloat = 0.80 {
        didSet {
            dashVerticalLineLayers.forEach { $0.lineWidth = dashLineWidth }
        }
    }
    
    var dashLineColor = UIColor.black.withAlphaComponent(0.8).cgColor {
        didSet {
            dashVerticalLineLayers.forEach { $0.strokeColor = dashLineColor }
        }
    }
}



