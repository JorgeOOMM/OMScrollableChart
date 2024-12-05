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

public struct OMScrollableChartRules {
    var chart: OMScrollableChart
    init(chart: OMScrollableChart) {
        self.chart = chart
    }
    
    public var rulesMarks = [Float]()
    func addToVerticalRuleMarks(leadingRule: RuleProtocol) {
        chart.dashlines.removeVerticalLineLayers()
        let leadingRuleWidth: CGFloat = leadingRule.ruleSize.width
        let width: CGFloat = chart.contentView.frame.width
        let fontSize = ruleFont.pointSize
        let maxIndex = rulesPoints.count - 1
        for (index, item) in rulesPoints.enumerated() {
            var yPos = item.y
            if index > 0 {
                if index < maxIndex {
                    yPos = item.y
                } else {
                    yPos = item.y
                }
            }
            let markPointLeft  = CGPoint(x: leadingRuleWidth, y: yPos - fontSize)
            let markPointRight = CGPoint(x: width, y: yPos - fontSize)
            chart.dashlines.lineForRuleMark(point: markPointLeft,
                                            endPoint: markPointRight)
        }
    }

    var rootRule: RuleProtocol?
    var footerRule: RuleProtocol?
    var topRule: RuleProtocol?
    var rules = [RuleProtocol]()
    var ruleLeadingAnchor: NSLayoutConstraint?
    var ruletopAnchor: NSLayoutConstraint?
    var rulebottomAnchor: NSLayoutConstraint?
    var rulewidthAnchor: NSLayoutConstraint?
    var ruleHeightAnchor: NSLayoutConstraint?
    var ruleFont = UIFont.systemFont(ofSize: 10, weight: .medium)
    var rulesPoints = [CGPoint]()
    var footerViewHeight: CGFloat = 60
    var topViewHeight: CGFloat = 20
    
    func hideRules() { rules.forEach { $0.isHidden = true }}
    func showRules() { rules.forEach { $0.isHidden = false }}
    
    /// Create and add rules
    mutating func configure(with color: UIColor, and footerColor: UIColor) {
        let rootRule = OMScrollableChartRuleLeading(chart: chart)
        rootRule.chart = chart
        rootRule.font = ruleFont
        rootRule.fontColor = color
        let footerRule = OMScrollableChartRuleFooter(chart: chart)
        footerRule.chart = chart
        footerRule.font = ruleFont
        footerRule.fontColor = footerColor
        self.rootRule = rootRule
        self.footerRule = footerRule
        rules.append(rootRule)
        rules.append(footerRule)
        // self.rules.append(topRule)
        
        //        if let topRule = topRule {
        //
        //        }
    }

    mutating func configureRules( using contentView: UIView) {
        addLeadingRuleIfNeeded(rootRule, contentView: contentView, view: nil)
        addFooterRuleIfNeeded(footerRule, contentView: contentView)
        rulebottomAnchor?.isActive = true
    }

    /// addLeadingRuleIfNeeded
    /// - Parameters:
    ///   - rule: ChartRuleProtocol
    ///   -mutating  view: UIView
    mutating func addLeadingRuleIfNeeded(_ rule: RuleProtocol?,
                                         contentView: UIView,
                                         view: UIView? = nil) {
        guard let rule = rule else {
            return
        }
        // rule.backgroundColor = .red
        assert(rule.type == .leading)
        if rule.superview == nil {
            rule.translatesAutoresizingMaskIntoConstraints = false
            if let view = view {
                view.insertSubview(rule, at: rule.type.rawValue)
            } else {
                rule.chart.insertSubview(rule, at: rule.type.rawValue)
            }
            let width = rule.ruleSize.width > 0 ?
                rule.ruleSize.width :
                contentView.bounds.width
            let height = rule.ruleSize.height > 0 ?
                rule.ruleSize.height :
                contentView.bounds.height
//            print(height, width)
            ruleLeadingAnchor = rule.leadingAnchor.constraint(equalTo: rule.chart.leadingAnchor)
            ruletopAnchor = rule.topAnchor.constraint(equalTo: contentView.topAnchor)
            rulewidthAnchor = rule.widthAnchor.constraint(equalToConstant: CGFloat(width))
            ruleHeightAnchor = rule.heightAnchor.constraint(equalToConstant: CGFloat(height))
            
            if let footerRule = footerRule {
                rulebottomAnchor = rule.bottomAnchor.constraint(equalTo: footerRule.bottomAnchor,
                                                                constant: -footerRule.ruleSize.height)
            }
            
            ruleLeadingAnchor?.isActive = true
            ruletopAnchor?.isActive = true
            // rulebottomAnchor?.isActive  = true
            rulewidthAnchor?.isActive = true
            ruleHeightAnchor?.isActive = true
        }
    }
    
    /// addFooterRuleIfNeeded
    /// - Parameters:
    ///   - rule: ruleFooter description
    ///   - view: UIView
    func addFooterRuleIfNeeded(_ rule: RuleProtocol? = nil,
                               contentView: UIView,
                               view: UIView? = nil)
    {
        guard let rule = rule else {
            return
        }
        assert(rule.type == .footer)
        // rule.backgroundColor = .red
        if rule.superview == nil {
            rule.translatesAutoresizingMaskIntoConstraints = false
            if let view = view {
                view.insertSubview(rule, at: rule.type.rawValue)
            } else {
                rule.chart.insertSubview(rule, at: rule.type.rawValue)
            }
            
            let width = rule.ruleSize.width > 0 ?
                rule.ruleSize.width :
                contentView.bounds.width
            let height = rule.ruleSize.height > 0 ?
                rule.ruleSize.height :
                contentView.bounds.height
        
            rule.leadingAnchor.constraint(equalTo: rule.chart.leadingAnchor).isActive = true
            rule.trailingAnchor.constraint(equalTo: rule.chart.trailingAnchor).isActive = true
            rule.topAnchor.constraint(equalTo: contentView.bottomAnchor,
                                      constant: 0).isActive = true
            rule.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
            rule.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    
    //     func addTopRuleIfNeeded(_ ruleTop: ChartRuleProtocol? = nil) {
    //        guard let ruleTop = ruleTop else {
    //            return
    //        }
    //        assert(ruleTop.type == .top)
    //        //ruleTop.removeFromSuperview()
    //        ruleTop.translatesAutoresizingMaskIntoConstraints = false
    //        ruleTop.backgroundColor = UIColor.clear
    //        self.addSubview(ruleTop)
    //        //        topView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    //        //        topView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    //        ruleTop.topAnchor.constraint(equalTo:  self.topAnchor).isActive = true
    //        ruleTop.heightAnchor.constraint(equalToConstant: CGFloat(topViewHeight)).isActive = true
    //        ruleTop.widthAnchor.constraint(equalToConstant: contentSize.width).isActive = true
    //        ruleTop.backgroundColor = .gray
    //    }
}
