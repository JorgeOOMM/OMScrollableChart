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

var DefaultFooterSectionsText = [NSLocalizedString("Ene"),
                                 NSLocalizedString("Feb"),
                                 NSLocalizedString("Mar"),
                                 NSLocalizedString("Abr"),
                                 NSLocalizedString("May"),
                                 NSLocalizedString("Jun"),
                                 NSLocalizedString("Jul"),
                                 NSLocalizedString("Ago"),
                                 NSLocalizedString("Sep"),
                                 NSLocalizedString("Oct"),
                                 NSLocalizedString("Nov"),
                                 NSLocalizedString("Dic")]

// MARK: - OMScrollableChartRuleFooter -
class ChartRuleFooter: UIStackView, RuleProtocol {
    var fontStrokeColor: UIColor = .black
    var leftInset: CGFloat = 16
    var chart: OMScrollableChart!
    var type: RuleType = .footer
    var ruleFooterViewSelectedSectionIndex: CGFloat = 0
    /// Border decoration.
    var borderDecorationWidth: CGFloat = 0.5
    var decorationColor: UIColor = UIColor.darkGreyBlueTwo
    var borderViews = [UIView]()
    var views: [UIView]? {
        return arrangedSubviews
    }
    var footerRuleHeight: CGFloat = 30 {
        didSet {
            setNeedsLayout()
        }
    }
    /// init
    ///
    /// - Parameter chart: OMScrollableChart
    required init(chart: OMScrollableChart!) {
        super.init(frame: .zero)
        self.chart = chart
        self.alignment = .top
        self.backgroundColor = .clear
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var ruleSize: CGSize {
        guard let rules = chart.rules else {
            return .zero
        }
        return CGSize(width: 0, height: rules.footerViewHeight)
    }
    var fontColor = UIColor.darkGreyBlueTwo {
        didSet {
            views?.forEach({($0 as? UILabel)?.textColor = fontColor})
        }
    }
    var font = UIFont.systemFont(ofSize: 14, weight: .thin) {
        didSet {
            views?.forEach({($0 as? UILabel)?.font = font})
        }
    }
    // Sections text.
    var footerSectionsText = DefaultFooterSectionsText {
        didSet {
            #if DEBUG
            if footerSectionsText.count > 0 {
                assert(footerSectionsText.count == Int(chart.numberOfSections))
            }
            #endif
            setNeedsLayout()
        }
    }

    ///
    /// create rule layout
    ///
    /// - Returns: Bool
    ///
    func layoutRule() -> Bool {
        self.borderViews.forEach{ $0.removeFromSuperview()}
        self.subviews.forEach{ $0.removeFromSuperview()}
        let width  = chart.sectionWidth
        let height = ruleSize.height * 0.5
        let numOfSections = Int(chart.numberOfSections)
        let currentMonth = Date.currentMonth
//        let symbols = self.chart.monthSymbols
        for monthIndex in currentMonth...numOfSections + currentMonth {
            Log.v("month Index: \(monthIndex % footerSectionsText.count) \(footerSectionsText[monthIndex % footerSectionsText.count])")
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = footerSectionsText[monthIndex % footerSectionsText.count]
            label.textAlignment = .center
            label.font = font
            label.sizeToFit()
            label.backgroundColor = .clear
            label.textColor = fontColor
            self.addArrangedSubview(label)
            label.widthAnchor.constraint(equalToConstant: width).isActive = true
                //label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: height).isActive = true
            
            borderViews.append(label.setBorder(border: .right(inset: 5),
                                            weight: borderDecorationWidth,
                                color: decorationColor.withAlphaComponent(0.24)))
        }
        borderViews.append(self.setBorder(border: .top(inset: 10),
                                      weight: borderDecorationWidth,
                       color: decorationColor.withAlphaComponent(0.24)))
        return true
    }

}


extension ChartRuleFooter {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            
            //
            // Get the view.
            //
            
            let location = touch.preciseLocation(in: self)
            let subviewIndex = subviewIndexFromPoint(location)
            if subviewIndex != Index.invalid.rawValue {
                _ = footerRuleSectionIndexSelected( at: CGFloat(subviewIndex))
                ruleFooterViewSelectedSectionIndex = CGFloat(subviewIndex)
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let views = views else { return}
        // Move the touch
        if let touch = touches.first {
            let idx = Int(ruleFooterViewSelectedSectionIndex)
            chart.ruleDelegate?.footerSectionDidTouchUpInsideMove(section: ruleFooterViewSelectedSectionIndex, selectedView: views[idx] ,
                                                                 location: touch.location(in: self))
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let views = views else { return}
        let idx = Int(ruleFooterViewSelectedSectionIndex)
        // Release the touch
        chart.ruleDelegate?.footerSectionDidTouchUpInsideRelease(section: ruleFooterViewSelectedSectionIndex,
                                                                 selectedView: views[idx] )
        ruleFooterViewSelectedSectionIndex = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         if !layoutRule() {
            Log.e("Unable to create the rule layout \(self)")
        }
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setNeedsLayout()
    }
}
