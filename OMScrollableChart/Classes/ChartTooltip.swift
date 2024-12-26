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
//
//

import UIKit

public class ChartTooltip: TooltipleableProtocol {
    private var contentView: UIView!
    private var bubbleView: OMBubbleTextView = OMBubbleTextView()
    init(contentView: UIView!) {
        self.contentView = contentView
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
    public func configure() {
        self.bubbleView.alpha           = TooltipTheme.tooltipAlpha
        self.bubbleView.backgroundColor = TooltipTheme.toolTipBackgroundColor
        self.bubbleView.font            = TooltipTheme.tooltipFont
        self.bubbleView.textAlignment   = .center
        // Layer
        self.bubbleView.layer.cornerRadius = 6
        self.bubbleView.layer.masksToBounds = true
        self.bubbleView.layer.borderColor = TooltipTheme.tooltipBorderColor
        self.bubbleView.layer.borderWidth = TooltipTheme.tooltipBorderWidth
        // Shadow
        self.bubbleView.layer.shadowColor = UIColor.black.cgColor
        self.bubbleView.layer.shadowOffset  = ScrollChartTheme.pointsLayersShadowOffset
        self.bubbleView.layer.shadowOpacity = 0.7
        self.bubbleView.layer.shadowRadius  = 3.0
        
        self.bubbleView.isFlipped = true
        
        self.contentView.addSubview(self.bubbleView)
    }
}
