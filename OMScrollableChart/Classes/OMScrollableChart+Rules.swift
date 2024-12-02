//// Copyright 2018 Jorge Ouahbi
////
//// Licensed under the Apache License, Version 2.0 (the "License");
//// you may not use this file except in compliance with the License.
//// You may obtain a copy of the License at
////
////     http://www.apache.org/licenses/LICENSE-2.0
////
//// Unless required by applicable law or agreed to in writing, software
//// distributed under the License is distributed on an "AS IS" BASIS,
//// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//// See the License for the specific language governing permissions and
//// limitations under the License.
//
//// https://stackoverflow.com/questions/35915853/how-to-show-tooltip-on-a-point-click-in-swift
//// https://itnext.io/swift-uiview-lovely-animation-and-transition-d34bd623391f
//// https://stackoverflow.com/questions/29674959/linear-regression-accelerate-framework-in-swift
//// https://gist.github.com/marmelroy/ed4bd675bd75c757ab7447d1b3488886

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

// https://stackoverflow.com/questions/35915853/how-to-show-tooltip-on-a-point-click-in-swift
// https://itnext.io/swift-uiview-lovely-animation-and-transition-d34bd623391f
// https://stackoverflow.com/questions/29674959/linear-regression-accelerate-framework-in-swift
// https://gist.github.com/marmelroy/ed4bd675bd75c757ab7447d1b3488886

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

extension OMScrollableChart {
    func appendRuleMark(_ value: Float) {
//        if value > 100000 {
//            let roundToNearest = round(value / 10000) * 10000
//            internalRulesMarks.append(roundToNearest)
//        } else if value > 10000 {
//            let roundToNearest = round(value / 1000) * 1000
//            internalRulesMarks.append(roundToNearest)
//        } else if value > 1000 {
//            let roundToNearest = round(value / 100) * 100
//            internalRulesMarks.append(roundToNearest)
//        } else if value > 100 {
//            let roundToNearest = round(value / 10) * 10
//            internalRulesMarks.append(roundToNearest)
//        } else {
//            internalRulesMarks.append(round(value))
//        }
        
        // Dont be adaptative, only round the 1000
        if value > 10000 {
            let roundToNearest = round(value / 1000) * 1000
            ruleManager.rulesMarks.append(roundToNearest)
        } else {
            ruleManager.rulesMarks.append(round(value))
        }
    }
    
    /// Calculate the rules marks positions
    
    func internalCalcRules(generator: ScaledPointsGeneratorProtocol) {
        // Get the polyline generator
        // + 2 is the limit up and the limit down
        let numberOfAllRuleMarks = Int(numberOfRuleMarks) + 2 - 1
        let roundedStep = generator.range / Float(numberOfAllRuleMarks)
        for ruleMarkIndex in 0 ..< numberOfAllRuleMarks {
            let value = generator.minimumValue + Float(roundedStep) * Float(ruleMarkIndex)
            appendRuleMark(value)
        }
        appendRuleMark(generator.maximumValue)
    }
    
    
//    func rootGenerator() -> LinearScaledPointsGeneratorProtocol? {
//        guard let rootRender = client.renders.filter({ $0.prop == RenderProperties.root }).first else {
//            return nil
//        }
//        switch rootRender.data.dataType {
//        case .discrete:
//            return rootRender.data.generator
//        case .stadistics:
//            return rootRender.data.generator
//        case .simplify:
//            return rootRender.data.generator
//        case .regress:
//            return rootRender.data.generator
//        }
//    }
    
    var drawableFrame: CGRect {
        return CGRect(origin: .zero,
                      size: contentView.frame.size)
    }
    
    func makeRulesPoints() -> Bool {
        let generator = scaledPointsGenerator[Renders.polyline.rawValue]
        guard numberOfRuleMarks > 0,generator.range != 0 else { return false }
        ruleManager.rulesMarks.removeAll()
        internalCalcRules(generator: generator)
        ruleManager.rulesPoints = generator.makePoints(data: rulesMarks,
                                                             size: drawableFrame.size)
        return true
    }
    
    ///
    /// layoutRules
    ///
    
    func layoutRules() {
        // Layout rules lines
        let oldRulesPoints = ruleManager.rulesPoints
        guard let leadingRule = ruleManager.rootRule else {
            return
        }
        guard makeRulesPoints() else { return }
        if ruleManager.rulesPoints == oldRulesPoints { return }
        // Update
        ruleManager.addToVerticalRuleMarks(leadingRule: leadingRule)
        // Mark for display the rule.
        ruleManager.rules.forEach { rule in
            _ = rule.layoutRule()
            rule.setNeedsDisplay()
        }
    }
}

