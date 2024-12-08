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

public enum Index: Int {
    case invalid = -1
}

// Uncategorized functions.
public func NSLocalizedString(_ key: String,
                              tableName: String? = nil,
                              bundle: Bundle = Bundle.main,
                              value: String = "",
                              comment: String = "") -> String {
    Foundation.NSLocalizedString(key, tableName: tableName,bundle: bundle,value: value,comment: comment)
}


extension RuleProtocol {
    /// footerRuleSectionIndexSelected
    /// - Parameter location: CGPoint
    func footerRuleSectionIndexSelected(at index: CGFloat? = nil ) -> Bool {
        guard let ruleViews = self.views else { return false }
        if let sectionSelectedIndex = index {
            let idx = Int(sectionSelectedIndex)
            let selectedFooterView = ruleViews[idx]
            guard let delegate = chart.renderDelegate else { return false }
            
            print("Notify section selected index",
                  sectionSelectedIndex,
                  selectedFooterView,
                  delegate)
            
            // notify
//            for render in RenderManager.shared.ruleEventsRenders {
//                // OMScrollableChartRenderableDelegateProtocol
//                delegate.didTouchFooterSectionView(chart: chart,
//                                                   renderIndex: render.index,
//                                                   sectionIndex: Int(sectionSelectedIndex),
//                                                   view: selectedFooterView)
//            }
            
            chart
                .flowDelegate?
                .footerSectionDidTouchUpInside(section: sectionSelectedIndex,
                                                         selectedView: selectedFooterView)
            
            return true
        }
        return false
    }
    func subviewIndexFromPoint(_ location: CGPoint) -> Int {
        guard let views = views else {
            return Index.invalid.rawValue
        }
        for (index, view) in views.enumerated() {
            if view.frame.contains(location) {
                //we found the finally touched view
                print(index,"Found it", view)
                return index
            }
        }
        return Index.invalid.rawValue
    }
}
//
// MARK: - OMScrollableChartRuleLeading -
//
class OMScrollableChartRuleLeading: UIView, RuleProtocol {
    private var labelViews = [UIView]()
    var type: RuleType = .leading
    var chart: OMScrollableChart!
    var decorationColor: UIColor = .black
    var fontStrokeColor: UIColor = .lightGray
    var ruleSize: CGSize = CGSize(width: 60, height: 0)
    var leftInset: CGFloat = 15
    required init(chart: OMScrollableChart!) {
        super.init(frame: .zero)
        self.chart = chart
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    var views: [UIView]?  {
        return labelViews
    }
    var fontColor = UIColor.black {
        didSet {
            views?.forEach({($0 as? UILabel)?.textColor = fontColor})
        }
    }
    var font = UIFont.systemFont(ofSize: 14, weight: .thin) {
        didSet {
            views?.forEach({($0 as? UILabel)?.font = font})
        }
    }
    func layoutRule() -> Bool {
        guard let chart = chart else {
            return false
        }
        labelViews.forEach({$0.removeFromSuperview()})
        labelViews.removeAll()
        let fontSize: CGFloat = font.pointSize
                
        for (index, item) in chart.rules.rulesPoints.enumerated() {
                if let stepString = chart.currencyFormatter.string(from: NSNumber(value: chart.rulesMarks[index])) {
                    let string = NSAttributedString(string: stepString,
                                                    attributes: [NSAttributedString.Key.font: self.font,
                                                                 NSAttributedString.Key.foregroundColor: self.fontColor,
                                                                 NSAttributedString.Key.strokeColor: self.fontStrokeColor])
                    let label = UILabel()
                    label.attributedText = string
                    label.sizeToFit()
                    label.frame = CGRect(x: leftInset,
                                     y: (item.y - fontSize),
                                         width: label.bounds.width,
                                         height: label.bounds.height)
                    self.addSubview(label)
                    labelViews.append(label)
                    // Notify the draw
                    chart.flowDelegate?.drawRootRuleText(in: label.frame, text: string)
                }
        }
        return true
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setNeedsLayout()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if !layoutRule() { // TODO: update layout
            Log.e("Unable to create the rule layout")
        }
    }
}
