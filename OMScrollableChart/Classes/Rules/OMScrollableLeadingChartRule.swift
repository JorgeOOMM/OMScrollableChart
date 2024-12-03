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

public enum Index: Int {
    case bad = -1
}

// Uncategorized functions.
public func NSLocalizedString(_ key: String,
                              tableName: String? = nil,
                              bundle: Bundle = Bundle.main,
                              value: String = "",
                              comment: String = "") -> String {
    Foundation.NSLocalizedString(key, tableName: tableName,bundle: bundle,value: value,comment: comment)
}


extension ChartRuleProtocol {
    /// onFooterRuleSectionIndexSelected
    /// - Parameter location: CGPoint
    func onFooterRuleSectionIndexSelected(at index: CGFloat? = nil ) -> Bool {
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
            return Index.bad.rawValue
        }
        for (index, view) in views.enumerated() {
            if view.frame.contains(location) {
                //we found the finally touched view
                print(index,"Found it", view)
                return index
            }
        }
        return Index.bad.rawValue
    }
}

//
// MARK: - OMScrollableLeadingChartRule -
//
class OMScrollableLeadingChartRule: UIView, ChartRuleProtocol {
    private var labelViews = [UIView]()
    var views: [UIView]?  {
        return labelViews
    }
    var type: ChartRuleType = .leading
    var chart: OMScrollableChart!
    var decorationColor: UIColor = .black

    required init(chart: OMScrollableChart!) {
        super.init(frame: .zero)
        self.chart = chart
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    var fontColor = UIColor.black {
        didSet {
            views?.forEach({($0 as? UILabel)?.textColor = fontColor})
        }
    }
    var fontStrokeColor = UIColor.lightGray
    var font = UIFont.systemFont(ofSize: 14, weight: .thin) {
        didSet {
            views?.forEach({($0 as? UILabel)?.font = font})
        }
    }
    var ruleSize: CGSize = CGSize(width: 60, height: 0)
    var leftInset: CGFloat = 15
    func layoutRule() -> Bool {
        guard let chart = chart else {
            return false
        }
        labelViews.forEach({$0.removeFromSuperview()})
        labelViews.removeAll()
        let fontSize: CGFloat = font.pointSize
                
        for (index, item) in chart.ruleManager.rulesPoints.enumerated() {
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
    var oldFrame: CGRect = .zero
    override func layoutSubviews() {
        super.layoutSubviews()
        if !layoutRule() { // TODO: update layout
           // Log.print("Unable to create the rule layout",.error)
        }
    }
}
