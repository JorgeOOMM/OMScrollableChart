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
//
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

import Accelerate
import UIKit
import GUILib

/*
 [topRule]
 ---------------------
 |
 rootRule   |
 |
 |
 |       footerRule
 |______________________
 */

import GUILib

// MARK: - RuleMarkProtocol
extension OMScrollableChart: RuleMarkProtocol {
    ///
    /// appendRuleMark
    ///
    /// - Parameter value: Float
    ///
    func appendRuleMark(_ value: Float) {
        // Dont be adaptative, only round the 1000
        if value > 10000 {
            let roundToNearest = round(value / 1000) * 1000
            rules?.rulesMarks.append(roundToNearest)
        } else {
            rules?.rulesMarks.append(round(value))
        }
    }
    
    ///
    /// Calculate the rules marks positions
    ///
    ///- Parameter pointScaler: <#pointScaler description#>
    ///
    func calcRuleMark(pointScaler: PointScalerGeneratorProtocol) {
        // Get the polyline generator
        // + 2 is the limit up and the limit down
        let numberOfAllRuleMarks = Int(numberOfRuleMarks) + 2 - 1
        let roundedStep = pointScaler.range / Float(numberOfAllRuleMarks)
        for ruleMarkIndex in 0 ..< numberOfAllRuleMarks {
            let value = pointScaler.minimumValue + Float(roundedStep) * Float(ruleMarkIndex)
            appendRuleMark(value)
        }
        appendRuleMark(pointScaler.maximumValue)
    }
    ///
    /// drawableFrame
    ///
    var drawableFrame: CGRect {
        return CGRect(origin: .zero,
                      size: contentView.frame.size)
    }
    
    ///
    /// makeRulesPoints
    ///
    
    func makeRuleMarkPoints() -> Bool {
        guard let pointScaler = self.pointsGeneratorModel?.pointScaler else {
            return false
        }
        guard numberOfRuleMarks > 0, pointScaler.range != 0 else { return false }
        rules?.rulesMarks.removeAll()
        calcRuleMark(pointScaler: pointScaler)
        rules?.rulesPoints = pointScaler.makePoints(data: rulesMarks,
                                                   size: drawableFrame.size)
        return true
    }
    
    ///
    /// layoutRules
    ///
    
    func layoutRules() {
        // Layout rules lines
        let oldRulesPoints = rules?.rulesPoints
        guard let leadingRule = rules?.rootRule else {
            return
        }
        guard makeRuleMarkPoints() else { return }
        if rules?.rulesPoints == oldRulesPoints { return }
        // Update
        rules?.addToVerticalRuleMarks(leadingRule: leadingRule)
        // Mark for display the rule.
        rules?.rules.forEach { rule in
            if !rule.layoutRule() {
                Log.e("Unable to create the rule layout \(rule)")
            }
            rule.setNeedsDisplay()
        }
    }
}

