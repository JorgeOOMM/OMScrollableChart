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


public protocol RuleDelegateProtocol {
    func footerSectionsTextChanged(texts: [String])
    func footerSectionDidTouchUpInside(section: CGFloat, selectedView: UIView?)
    func footerSectionDidTouchUpInsideMove(section: CGFloat, selectedView: UIView?, location: CGPoint)
    func footerSectionDidTouchUpInsideRelease(section: CGFloat, selectedView: UIView?)
    func numberOfPagesChanged(pages: CGFloat)
    func contentSizeChanged(contentSize: CGSize)
    func frameChanged(frame: CGRect)
    func dataPointsChanged(dataPoints: [Float], for index: Int)
    func drawRootRuleText(in frame: CGRect, text: NSAttributedString)
    func renderDataTypeChanged(in dataOfRender: RenderType, for index: Int)
    func updateRenderLayers( index: Int, with layers: [CALayer])
    func updateRenderData(index: Int, data: Data?)
    func deviceRotation()
    func regeneratingRendersLayers()
    
}

enum RuleType: Int {
    case leading = 0
    case footer = 1
    case top = 2
    case trailing = 3
}

protocol RuleProtocol: UIView {
    var chart: OMScrollableChart! {get set}
    init(chart: OMScrollableChart!)
    var type: RuleType {get set}
    
    var font: UIFont {get set}
    var fontColor: UIColor {get set}
    var fontStrokeColor: UIColor {get set}
    var decorationColor: UIColor {get set}
    var leftInset: CGFloat {get set}
    var ruleSize: CGSize {get}
    var views: [UIView]? {get}
    func layoutRule() -> Bool
    func footerRuleSectionIndexSelected(at index: CGFloat?) -> Bool
    func subviewIndexFromPoint(_ location: CGPoint) -> Int
}
