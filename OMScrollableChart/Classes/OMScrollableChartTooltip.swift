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
//  OMScrollableChartTooltip
//
//  Created by Jorge Ouahbi on 16/08/2024.

import UIKit

// MARK: TooltipProtocol

public protocol TooltipProtocol {
    var string: String? {get set}
//    var frame: CGRect  {get }
    func displayTooltip(_ position: CGPoint, duration: TimeInterval)
    func moveTooltip(_ position: CGPoint, duration: TimeInterval)
    func hideTooltip(_ position: CGPoint, duration: TimeInterval)
    mutating func configure()
}

public struct OMScrollableChartTooltip: TooltipProtocol {
    private var chart: OMScrollableChart!
    private var bubbleView: OMBubbleTextView = OMBubbleTextView()
    init(chart: OMScrollableChart!) {
        self.chart = chart
    }
    // text
    public var string: String? {
        didSet {
            self.bubbleView.string = self.string
        }
    }
    public func displayTooltip(_ position: CGPoint, duration: TimeInterval = 0.5) {
        self.bubbleView.displayTooltip(position, duration: duration)
    }
    public func moveTooltip(_ position: CGPoint, duration: TimeInterval = 0.2) {
        self.bubbleView.moveTooltip(position, duration: duration)
    }
    public func hideTooltip(_ position: CGPoint, duration: TimeInterval = 4.0) {
        self.bubbleView.hideTooltip(position, duration: duration)
    }
//    public var frame: CGRect {
//
//        // Calculate the biggest size that fits in the given CGSize
//        let newSize = self.bubbleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
//
//        // Set the textView's size to be whatever is bigger: The fitted width or the fixedWidth
//        let size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//
//        
//        let ratio: CGFloat = (1.0 / 8.0) * 0.5
//        let superHeight = chart.superview?.frame.height ?? 1
//        let estimatedTooltipHeight = superHeight * ratio
//        return CGRect(x: 0,
//                      y: 0,
//                      width: 128,
//                      height: estimatedTooltipHeight > 0 ? estimatedTooltipHeight : 37.0)
//    }

    mutating public func configure() {
        self.bubbleView.frame = .zero
        self.bubbleView.alpha = chart.tooltipAlpha
        self.bubbleView.font  = chart.tooltipFont
        self.bubbleView.textAlignment = .center
        self.bubbleView.layer.cornerRadius = 6
        self.bubbleView.layer.masksToBounds = true
        self.bubbleView.backgroundColor = chart.toolTipBackgroundColor
        self.bubbleView.layer.borderColor = chart.tooltipBorderColor
        self.bubbleView.layer.borderWidth = chart.tooltipBorderWidth
        // Shadow
        self.bubbleView.layer.shadowColor = UIColor.black.cgColor
        self.bubbleView.layer.shadowOffset  = chart.pointsLayersShadowOffset
        self.bubbleView.layer.shadowOpacity = 0.7
        self.bubbleView.layer.shadowRadius  = 3.0
        
        self.bubbleView.isFlipped = true
        
        self.chart.contentView.addSubview(self.bubbleView)
    }
}