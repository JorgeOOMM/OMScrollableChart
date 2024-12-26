// Copyright 2024 Jorge Ouahbi
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
// MARK: - RuleDelegateProtocol
public class RuleDelegate: RuleDelegateProtocol {
    public func footerSectionDidTouchUpInsideMove(section: CGFloat, selectedView: UIView?, location: CGPoint) {
        Log.v("footerSectionDidTouchUpInsideMove", section)
    }
    public func deviceRotation() {
        Log.v("deviceRotation")
    }
    public func footerSectionDidTouchUpInside(section: CGFloat, selectedView: UIView?) {
        Log.v("footerSectionDidTouchUpInside", section)
    }
    public func footerSectionDidTouchUpInsideRelease(section: CGFloat, selectedView: UIView?) {
        Log.v("footerSectionDidTouchUpInsideRelease", section)
    }
    public func updateRenderLayers(index: Int, with layers: [CALayer]) {
        Log.v("updateRenderLayers", Renders(rawValue: index)!, layers.count)
    }
    public func updateRenderData(index: Int, data: Data?) {
        Log.v("updateRenderData", Renders(rawValue: index)!, data ?? "")
    }
    public func renderDataTypeChanged(in dataOfRender: RenderType, for index: Int) {
        Log.v("renderDataTypeChanged", dataOfRender, Renders(rawValue: index)!)
    }
    public func regeneratingRendersLayers() {
        Log.v("regeneratingRendersLayers")
    }
    public func drawRootRuleText(in frame: CGRect, text: NSAttributedString) {
        Log.v("drawRootRuleText", frame)
    }
    public func footerSectionsTextChanged(texts: [String]) {
        Log.v("footerSectionsTextChanged", texts)
    }
    public func numberOfPagesChanged(pages: CGFloat) {
        Log.v("numberOfPagesChanged", pages)
    }
    public func contentSizeChanged(contentSize: CGSize) {
        Log.v("contentSizeChanged", contentSize)
    }
    public func frameChanged(frame: CGRect) {
        print("frameChanged", frame)
    }
    public func dataPointsChanged(dataPoints: [Float], for index: Int) {
        print("dataPointsChanged", Renders(rawValue: index) ?? "")
    }
}
