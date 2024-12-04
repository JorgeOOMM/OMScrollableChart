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


public class OMScrollableChartRuleFlow: RuleDelegateProtocol {
    public func footerSectionDidTouchUpInsideMove(section: CGFloat, selectedView: UIView?, location: CGPoint) {
        print("[FLOW] footerSectionDidTouchUpInsideMove", section)
    }
    
    public func deviceRotation() {
        print("[FLOW] deviceRotation")
    }
    
    public func footerSectionDidTouchUpInside(section: CGFloat, selectedView: UIView?) {
        print("[FLOW] footerSectionDidTouchUpInside", section)
    }
    
    public func footerSectionDidTouchUpInsideRelease(section: CGFloat, selectedView: UIView?) {
        print("[FLOW] footerSectionDidTouchUpInsideRelease", section)
    }
    
    public func updateRenderLayers(index: Int, with layers: [CALayer]) {
        print("[FLOW] updateRenderLayers", Renders(rawValue: index)!, layers.count)
    }
    public func updateRenderData(index: Int, data: Data?) {
        print("[FLOW] updateRenderData", Renders(rawValue: index)!, data ?? "")
    }
    
    public func renderDataTypeChanged(in dataOfRender: RenderType, for index: Int) {
        print("[FLOW] renderDataTypeChanged", dataOfRender, Renders(rawValue: index)!)
    }
    public func regeneratingRendersLayers() {
        print("[FLOW] regeneratingRendersLayers")
    }
    public func drawRootRuleText(in frame: CGRect, text: NSAttributedString) {
        print("[FLOW] drawRootRuleText", frame)
    }
    public func footerSectionsTextChanged(texts: [String]) {
        print("[FLOW] footerSectionsTextChanged", texts)
    }
    
    public func numberOfPagesChanged(pages: CGFloat) {
        print("[FLOW] numberOfPagesChanged", pages)
    }
    
    public func contentSizeChanged(contentSize: CGSize) {
        print("[FLOW] contentSizeChanged", contentSize)
    }
    
    public func frameChanged(frame: CGRect) {
        print("[FLOW] frameChanged", frame)
    }
    
    public func dataPointsChanged(dataPoints: [Float], for index: Int) {
        print("[FLOW] dataPointsChanged", Renders(rawValue: index)!)
    }
}
