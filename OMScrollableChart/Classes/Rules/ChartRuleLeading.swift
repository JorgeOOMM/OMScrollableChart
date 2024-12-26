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

//
// MARK: - ChartRuleLeading -
//
class ChartRuleLeading: UIView, RuleProtocol {
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
    @available(*, unavailable, message: "Nib are unsupported")
    required init?(coder: NSCoder) {
        fatalError("Nib are unsupported")
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
        labelViews.forEach{$0.removeFromSuperview()}
        labelViews.removeAll()
        let fontSize: CGFloat = font.pointSize
        guard let rules = chart.rules else {
            return false
        }
        for (index, item) in rules.rulesPoints.enumerated() {
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
                    chart.ruleDelegate?.drawRootRuleText(in: label.frame, text: string)
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
        if !layoutRule() {
            Log.e("Unable to create the rule layout \(self)")
        }
    }
}
