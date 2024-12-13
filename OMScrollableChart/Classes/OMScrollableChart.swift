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

import UIKit
import Accelerate
import GUILib
// swiftlint:disable file_length
// swiftlint:disable type_body_length


extension UIColor {
    @nonobjc class var paleGrey: UIColor {
        return UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var greyishBlue: UIColor {
        return UIColor(red: 89.0 / 255.0, green: 135.0 / 255.0, blue: 164.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var darkGreyBlueTwo: UIColor {
        return UIColor(red: 50.0 / 255.0, green: 81.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0)
    }
}


struct ScrollChartAnimationKeys {
    static let renderPathAnimationGroupKey: String = "renderPathAnimationGroup"
    static let renderPathAnimationKey: String = "renderPathAnimation"
    static let renderPositionAnimationGroupKey: String = "renderPositionAnimationGroup"
    static let renderPositionAnimationKey: String = "renderPositionAnimation"
    static let renderOpacityAnimationKey: String = "renderOpacityAnimation"
    static let renderOpacityClearAnimationKey: String = "renderOpacityClearAnimation"
    static let renderAnimateLineSelectionKey: String = "renderAnimateLineSelection"
    static let renderAnimateFadingPointsKey: String = "renderAnimateFadingPoints"
    
}
struct ScrollChartConfiguration {
    static let maxNumberOfRegressionPoints: Int = 10
    static let scrollingProgressDuration: TimeInterval = 1.2
    static let maxNumberOfRenders: Int = 10
}

struct ScrollChartTheme {
    static let pointSize: CGSize = CGSize(width: 12, height: 12)
    static let pointsColor: UIColor = UIColor.darkGreyBlueTwo
    static let selectedPointSize: CGSize =  CGSize(width: 15, height: 15)
    static let selectedPointColor: UIColor = UIColor.paleGrey
    static let currentPointSize: CGSize = CGSize(width: 11, height: 11)
    static let currentPointColor: UIColor = UIColor.greyishBlue
    static let polylineColor: UIColor = UIColor.darkGreyBlueTwo
    static let polylineLineWidth: CGFloat = 4
    static let segmentsColor: UIColor = UIColor.greyishBlue
    static let segmentLineWidth: CGFloat  = polylineLineWidth * 2
}

@objcMembers
public class OMScrollableChart: UIScrollView, ChartProtocol, CAAnimationDelegate {
    private var pointsLayer: OMGradientShapeClipLayer =  OMGradientShapeClipLayer()
    var polylineLayer: OMGradientShapeClipLayer =  OMGradientShapeClipLayer()
    var rootRule: RuleProtocol?
    var footerRule: RuleProtocol?
    var topRule: RuleProtocol?
    var allRules = [RuleProtocol]() // todo
    var flowDelegate: RuleDelegateProtocol? = OMScrollableChartRuleFlow()
    weak var dataSource: DataSourceProtocol?
    weak var renderSource: RenderableProtocol?
    weak var renderDelegate: RenderableDelegateProtocol?
//    var isSelectedRenderLayersSegment: Bool = false
    var selectedSegmentRenderLayer: CALayer?
    var selectedPointRenderLayer: CALayer?
    var pathsToAnimate = [[UIBezierPath]]()
    
    var oldFrame: CGRect = .zero
    var numberOfRegressValues: Int = 1
    var renderLayers: [[OMGradientShapeClipLayer]] = []
    var pointsRender: [[CGPoint]] = []
    var renderDataPoints: [[Float]] = []
    internal var renderType: [RenderType] = []
    var averagedData: [ChartData?] = []
    var linregressData: [ChartData?] = []
    var discreteData:  [ChartData?] = []
    var approximationData:  [ChartData?] = []
    
    // cache hashed frame + points
//    var layoutCache = [String: Any]()
//    var isLayoutCacheActive: Bool = true
//    var cacheTrackingLayout: Int = 0
    var isScrollAnimation: Bool = false
    var isScrollAnimnationDone: Bool = false
    
    var isScrolling: Bool = false
    
//    var isAnimatePointsClearOpacity: Bool = false
//    var isAnimatePointsClearOpacityDone: Bool = false
    var ridePathAnimation: CAAnimation? = nil
    var layerToRide: CALayer?
    var ridePath: Path?
    
    var currentLocale: Locale = Locale(identifier: "es_ES")
    
    // MARK: - Tooltip -

//    var scaledPointsGenerator =
//    [InlineScaledPointsGenerator](repeating: InlineScaledPointsGenerator([], 
//                                                                         size: .zero,
//                                                                         insets: UIEdgeInsets(top: 0, left: 0,bottom: 0,right: 0)),
//                                                                         count: ScrollChartConfiguration.maxNumberOfRenders)
    
    var pointsGeneratorModel: PointsGeneratorModelProtocol?
    var polylineGradientFadePercentage: CGFloat = 0.4
    var drawPolylineGradient: Bool =  true
    var lineColor = UIColor.greyishBlue
    var lineWidth: CGFloat = 1
    
    var footerViewHeight: CGFloat = 30
    var topViewHeight: CGFloat = 20
    var ruleLeadingAnchor: NSLayoutConstraint?
    var ruletopAnchor: NSLayoutConstraint?
    var rulebottomAnchor: NSLayoutConstraint?
    var rulewidthAnchor: NSLayoutConstraint?
    var ruleHeightAnchor: NSLayoutConstraint?
    var ruleFont = UIFont.systemFont(ofSize: 10, weight: .medium)
    var rulesPoints = [CGPoint]()
    var animatePolyLine = false
    var animateDashLines: Bool = false
    var animatePointLayers: Bool = true
//    var isAnimateLineSelection: Bool = true
    var pointsLayersShadowOffset = CGSize(width: 0, height: 0.5)
    var selectedColor = UIColor.red
    var selectedOpacy: Float = 1.0
    var unselectedOpacy: Float = 0
    var unselectedColor = UIColor.clear
    
    // MARK: - Tooltip properties -
    var tooltipBorderColor = UIColor.black.cgColor
    var tooltipBorderWidth: CGFloat = 0.0
    var toolTipBackgroundColor: UIColor = UIColor.clear
    var tooltipFont = UIFont.systemFont(ofSize: 12, weight: .light)
    var tooltipAlpha: CGFloat = 0
    
    // MARK: - DashLines -
    public lazy var dashlines: OMScrollableChartDashLines = {
        let lines = OMScrollableChartDashLines(contentView: contentView)
        return lines
    }()
    // MARK: - Rules -
    public lazy var rules: OMScrollableChartRules = {
        let rule = OMScrollableChartRules(chart: self)
        return rule
    }()
    
    public lazy var tooltip: OMScrollableChartTooltip = {
        let tip = OMScrollableChartTooltip(chart: self)
        return tip
    }()
    
    // Content view
    lazy var contentView: UIView =  {
        let lazyContentView = UIView(frame: self.bounds)
        self.addSubview(lazyContentView)
        return lazyContentView
    }()
    
    lazy var growAnimation: CAAnimation = {
        return growAnimation(duration: 1.0)
    }()
    
    
    lazy var shakeGrowAnimation: CAAnimation = {
        return shakeGrowAnimation(duration: 0.5)
    }()
    
    
    // MARK: - Data Bounds -
    // Number of sections per page
    // For example: mouths : 6
    var numberOfSectionsPerPage: Int {
        return dataSource?.numberOfSectionsPerPage(chart: self) ?? 1
    }
    // Number total of sections
    var numberOfSections: Int {
        return numberOfSectionsPerPage * Int(numberOfPages)
    }
    // Section width
    var sectionWidth: CGFloat {
        return self.contentSize.width/CGFloat(numberOfSections)
    }
    // Number total of pages
    var numberOfPages: CGFloat = 1 {
        didSet {
            updateContentSize()
        }
    }
    // MARK: - Polyline -
    /// Polyline Interpolation
    var polylineInterpolation: PolyLineInterpolation = .catmullRom(0.5) {
        didSet {
            updateLayout()
        }
    }
    lazy var numberFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.maximumFractionDigits = 0
        // localize to your grouping and decimal separator
        currencyFormatter.locale = self.currentLocale
        return currencyFormatter
    }()

    lazy var currencyFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        // localize to your grouping and decimal separator
        currencyFormatter.locale = self.currentLocale
        return currencyFormatter
    }()
    
    var numberOfElementsToAverage: Int = 1 {
        didSet {
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    // 0.0 -> 5.0
    var simplifiedTolerance: CGFloat = 0.0 {
        didSet {
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    // MARK: - Rules -
    var numberOfRuleMarks: CGFloat = 4 {
        didSet {
            setNeedsLayout()
        }
    }
    // MARK: - Rules -
    
    var rulesMarks: [Float] {
        return rules.rulesMarks.sorted(by: { !($0 > $1) })
    }
    
    // MARK: - Footer -
    var decorationFooterRuleColor = UIColor.black {
        didSet {
            rules.footerRule?.decorationColor = decorationFooterRuleColor
        }
    }
    
    // MARK: - Font color -
    var fontFooterRuleColor = UIColor.darkGreyBlueTwo {
        didSet {
            rules.footerRule?.fontColor = fontFooterRuleColor
        }
    }
    
    var fontRootRuleColor = UIColor.black {
        didSet {
            rules.rootRule?.fontColor = fontRootRuleColor
        }
    }
    
    var fontTopRuleColor = UIColor.black {
        didSet {
            rules.topRule?.fontColor = fontTopRuleColor
        }
    }
    
    var footerRuleBackgroundColor = UIColor.black {
        didSet {
            rules.footerRule?.backgroundColor = footerRuleBackgroundColor
        }
    }
    
    // MARK: - KVO -
    
    private var contentSizeKOToken: NSKeyValueObservation?
    private var contentOffsetKOToken: NSKeyValueObservation?
    
    // MARK: -  register/unregister notifications and KVO
    
    private func registerNotifications() {
#if swift(>=4.2)
        let notificationName = UIDevice.orientationDidChangeNotification
#else
        let notificationName = NSNotification.Name.UIDeviceOrientationDidChange
#endif
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRotation),
                                               name: notificationName,
                                               object: nil)
        
        contentOffsetKOToken = observe(\.contentOffset) { [weak self] object, _ in
            // the `[weak self]` is to avoid strong reference cycle; obviously,
            // if you don't reference `self` in the closure, then `[weak self]` is not needed
            // print("contentOffset is now \(object.contentOffset)")
            guard let selfWeak = self else {
                return
            }
            for layer in selfWeak.dashlines.dashVerticalLineLayers {
                CATransaction.withDisabledActions {
                    var layerFrame = layer.frame
                    layerFrame.origin = object.contentOffset
                    layer.frame = layerFrame
                }
            }
        }
        
        contentSizeKOToken = observe(\.contentSize) { [weak self] object, _ in
            //             the `[weak self]` is to avoid strong reference cycle; obviously,
            //             if you don't reference `self` in the closure, then `[weak self]` is not needed
            guard let selfWeak = self else {
                return
            }
            Log.v("contentSize is now \(object.contentSize) \(object.bounds)")
        }
    }
    
    // Unregister the ´orientationDidChangeNotification´ notification
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        unregisterNotifications()
        contentOffsetKOToken?.invalidate()
        contentOffsetKOToken = nil
        contentSizeKOToken?.invalidate()
        contentSizeKOToken = nil
    }
    // MARK: - handleRotation -
    @objc func handleRotation() {
        self.updateContentSize()
    }
    // Setup all the view/subviews
    func onMoveToSuperview() {
        
        let scaledPoints = ScaledPointsGenerator()
        self.pointsGeneratorModel = PointsGeneratorModel(pointScaler: scaledPoints)
        
        self.renderDelegate = self
        self.renderSource   = self
        self.clearsContextBeforeDrawing = true
        registerNotifications()
        // Setup the UIScrollView
        delegate = self
        if #available(iOS 11, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
        // configure rules
        rules.configure()
        // configure tooltip
        tooltip.configure()
    }
    ///
    /// Calculate the content height
    ///
    /// - Returns: Content height
    ///
    func contentSizeHeight() -> CGFloat {
        return contentSize.height - rules.footerViewHeight
    }
    
    ///
    /// Update the chart content size and the contentView frame
    ///
    func updateContentSize() {
        self.layoutIfNeeded()
        let newValue = CGSize(width: bounds.width * CGFloat(numberOfPages),
                              height: bounds.height)
        if contentSize != newValue {
            contentSize = newValue
            contentView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: contentSize.width,
                                       height: contentSizeHeight())
            
            flowDelegate?.contentSizeChanged(contentSize: newValue)
            updateLayout()
        }
    }
    ///
    /// Update the chart  data source for the render points for each render
    ///
    func updateRenderDataPoints() {
        guard let dataSource = self.dataSource else {
            Log.e("Not data source found.")
            return
        }
        if let render = self.renderSource, render.numberOfRenders > 0  {
            // Get the data points for all renders,
            // inclusive the case that only exist one render; index 0
            for index in 0...render.numberOfRenders - 1 {
                let dataForPoints = dataSource.dataPoints(chart: self,
                                                       renderIndex: index,
                                                       section: 0)
                var dataForPointsUpdate = true
                if index < renderDataPoints.count {
                    // Check for unchanged render data
                    let dataForPointsHash = dataForPoints.hashValue
                    let currentDataForPointsHash = renderDataPoints[index].hashValue
                    if currentDataForPointsHash == dataForPointsHash {
                        dataForPointsUpdate = false
                    }
                }
                if dataForPointsUpdate {
                    // Store the data for points and notify it
                    self.renderDataPoints.insert(dataForPoints, at: index)
                    self.flowDelegate?.dataPointsChanged(dataPoints: dataForPoints, for: index)
                }
            }
        }
    }
    ///
    /// Update the chart footer rule sections text
    ///
    func updateFooterRuleSectionsText() {
        guard let dataSource = self.dataSource else {
            Log.e("Not data source found.")
            return
        }
        if let footerRule = self.footerRule as? OMScrollableChartRuleFooter {
            if let texts = dataSource.footerSectionsText(chart: self) {
                if texts != footerRule.footerSectionsText {
                    footerRule.footerSectionsText = texts
                    flowDelegate?.footerSectionsTextChanged(texts: texts)
                }
            }
        }
    }
    ///
    /// Update the chart number of pages
    ///
    /// - Returns: Bool
    ///
    func updateNumberOfPages() -> Bool {
        let oldNumberOfPages = numberOfPages
        guard let numberOfPoints = self.renderDataPoints.map({$0.count}).max() else {
            return false
        }
        // Add the maximun allowed regression points to the max nu,ber of render points
        let maximunNumberOfPoints = CGFloat(numberOfPoints + ScrollChartConfiguration.maxNumberOfRegressionPoints)
        let newNumberOfPages = maximunNumberOfPoints / CGFloat(self.numberOfSectionsPerPage)
        if oldNumberOfPages != newNumberOfPages {
            Log.v("numberOfPages was changed: \(oldNumberOfPages) -> \(newNumberOfPages)")
            self.numberOfPages = newNumberOfPages
            flowDelegate?.numberOfPagesChanged(pages: newNumberOfPages)
            return true
        }
        return false
    }
    ///
    /// Update the chart basic source data
    ///
    /// - Returns: Bool
    ///
    func updateBasicSourceData() -> Bool {
        // get the data points
        updateRenderDataPoints()
        // update the footer rule section texts
        updateFooterRuleSectionsText()
        // update teh number of pages.
        let numberOfPagesChanged = updateNumberOfPages()
        return numberOfPagesChanged
    }
}

extension OMScrollableChart {
    public typealias ChartData = (points: [CGPoint], data: [Float])
    var allPointsRender: [CGPoint] { return  pointsRender.flatMap{$0}}
    var allDataPointsRender: [Float] { return  renderDataPoints.flatMap{$0}}
    // Polyline render index 0
    var polylinePoints: [CGPoint]?  {
        guard pointsRender.isEmpty == false else {
            return nil
        }
        return pointsRender[Renders.polyline.rawValue]
    }
    var polylineDataPoints: [Float]? {
        guard renderDataPoints.isEmpty == false else {
            return nil
        }
        return renderDataPoints[Renders.polyline.rawValue]
    }
    // Polyline render index 1
    var pointsPoints: [CGPoint]?  {
        guard pointsRender.isEmpty == false else {
            return nil
        }
        return pointsRender[Renders.points.rawValue]
    }
    var pointsDataPoints: [Float]? {
        guard renderDataPoints.isEmpty == false else {
            return nil
        }
        return renderDataPoints[Renders.points.rawValue]
    }
    // Selected Layers
    var renderSelectedPointsLayer: CAShapeLayer? {
        guard renderLayers.isEmpty == false else {
            return nil
        }
        return renderLayers[Renders.selectedPoint.rawValue].first
    }
    func minPoint(in renderIndex: Int) -> CGPoint? {
        return pointsRender[renderIndex].max(by: {$0.x > $1.x})
    }
    func maxPoint(in renderIndex: Int) -> CGPoint? {
        return pointsRender[renderIndex].max(by: {$0.x <= $1.x})
    }
    // MARK: - Render layer -
    var visibleLayers: [CAShapeLayer] {
        return allRendersLayers.filter({$0.opacity == 1.0})
    }
    var invisibleLayers: [CAShapeLayer] {
        return allRendersLayers.filter({$0.opacity == 0})
    }
    var allRendersLayers: [CAShapeLayer]  {
        return renderLayers.flatMap({$0})
    }
    ///
    /// Remove all layers
    ///
    private func removeAllLayers() {
        self.renderLayers.forEach{$0.forEach{$0.removeFromSuperlayer()}}
        self.renderType = []
        self.renderLayers = []
    }
    ///
    /// Regenerate Renders Layers
    ///
    /// - Parameter numberOfRenders: Number of Renders
    ///
    func regenerateRendersLayers(_ numberOfRenders: Int) {
        guard let dataSource = self.dataSource else {
            Log.e("Not data source found.")
            return
        }
        resetRenderData()
        // Render layers
        for renderIndex in 0..<numberOfRenders {
            guard renderDataPoints[renderIndex].isEmpty == false else {
                print("skip \(renderIndex) for regenerate layers")
                continue
            }
            // Get the render data. ex: discrete / approx / averaged / regression for each render
            let dataOfRender = dataSource.dataOfRender(chart: self, renderIndex: renderIndex)
            flowDelegate?.renderDataTypeChanged(in: dataOfRender, for: renderIndex)
            renderLayers(renderIndex, renderAs: dataOfRender)
        }
        // Add layers
        for (layerIndex, layer) in allRendersLayers.enumerated() {
            // Insert the render layers
            self.contentView.layer.insertSublayer(layer, at: UInt32(layerIndex))
        }
    }
    
    ///
    /// Reset the Render Data
    ///
    private func resetRenderData() {
        // points and layers
        pointsRender.removeAll()
        renderLayers.removeAll()
        // data
        discreteData.removeAll()
        averagedData.removeAll()
        linregressData.removeAll()
        approximationData.removeAll()
        
        renderType.removeAll()
    }
    
    func rendersIsVisible(renderIndex: Int) -> Bool {
        if let renderDelegate = renderDelegate {
            return renderDelegate.layerOpacity(chart: self, renderIndex: renderIndex) == 1.0
        }
        return false
    }
    
    ///
    /// Layout the chart renders layers
    ///
    /// - Parameters:
    ///
    ///   - numberOfRenders: numberOfRenders
    ///
    func layoutRenders(_ numberOfRenders: Int) {
        guard let renderDelegate = renderDelegate else { return }
        regenerateRendersLayers(numberOfRenders)
        // update with animation
        for renderIndex in 0..<numberOfRenders {
            // Get the opacity
            let  layerOpacity = renderDelegate.layerOpacity(chart: self, renderIndex: renderIndex)
            // update it
            updateRenderLayersOpacity(for: renderIndex, layerOpacity: layerOpacity)
            
            let timing = renderDelegate.queryAnimation(chart: self, renderIndex: renderIndex)
            var repeat_times: Int = 0
            switch timing {
            case .none:
                break
            case .repeatn(let n):
                repeat_times = n
            case .infinite:
                break
            case .oneShot:
                repeat_times = 1
                break
            }
            
            if repeat_times > 0 {
                print("Animating the render:\(renderIndex) layers \(repeat_times).")
                animateRenderLayers(renderIndex,
                                    layerOpacity: layerOpacity)
            } else {
                print("The render \(renderIndex) dont want animate its layers.")
            }
        }
    }
    
    fileprivate func regenerateLayerTree() {
        print("Regenerating the layer tree for: \(self.contentView.bounds)")
        removeAllLayers()
        if contentView.superview != nil {
            rules.configureRules(using: contentView)
        }
        if let render = self.renderSource,
           render.numberOfRenders > 0  {
            // layout renders
            layoutRenders(render.numberOfRenders)
            // layout rules
            layoutRules()
        }
        
        if !isScrollAnimnationDone && isScrollAnimation {
            isScrollAnimnationDone = true
            scrollingProgressAnimatingToPage(ScrollChartConfiguration.scrollingProgressDuration, page: 1)
        } else {
            // Only animate if the points if the render its visible.
//            if rendersIsVisible(renderIndex: Renders.points.rawValue) {
//                animatePointsClearOpacity()
//            }
        }
    }
    
    /// Update the chart layout
    ///
    func updateLayout() {
        Log.v("updateLayout for render points bounded at frame \(self.frame)")
        guard allDataPointsRender.count > 0 else {
            return
        }
        // Create the points from the discrete data using the renders
        regenerateLayerTree()
    }
    ///
    /// Create the subviews layout chart for the current frame
    ///
    private func layoutSubviewsForFrame() {
        let updated = self.updateBasicSourceData()
        Log.v("updateDataSourceData() \(updated)")
        if updated {
            self.updateLayout()
        }
    }
}
// MARK: - overrides
extension OMScrollableChart {
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.onMoveToSuperview()
    }
    public override var contentOffset: CGPoint {
        get {
            return super.contentOffset
        }
        set(newValue) {
            if self.contentOffset != newValue {
                super.contentOffset = newValue
            }
        }
    }
    public override var frame: CGRect {
        set(newValue) {
            super.frame = newValue
            self.setNeedsLayout()
        }
        get { return super.frame }
    }
    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        self.updateRendersOpacity()
    }
    public override func layoutSubviews() {
        self.backgroundColor = .clear
        super.layoutSubviews()
        guard oldFrame != self.frame else {
            return
        }
        self.oldFrame = self.frame
        flowDelegate?.frameChanged(frame: frame)
        layoutSubviewsForFrame()
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let ctx = UIGraphicsGetCurrentContext() {
            if drawPolylineGradient {
                polylineLayer.strokeGradient(ctx: ctx,
                               points: polylinePoints,
                               color: lineColor,
                               lineWidth: lineWidth,
                               fadeFactor: polylineGradientFadePercentage)
            } else {
                ctx.saveGState()
                // Clip to the path
                if let path = polylineLayer.path {
                    let pathToFill = UIBezierPath(cgPath: path)
                    self.lineColor.setFill()
                    pathToFill.fill()
                }
                ctx.restoreGState()
            }
        }
        // drawVerticalGridLines()
        // drawHorizalGridLines()
        // Specify a border (stroke) color.
        // UIColor.black.setStroke()
        // pathVertical.stroke()
        // pathHorizontal.stroke()
    }
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        onTouchesBegan(touches)
    }
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        super.touchesMoved(touches, with: event)
        onTouchesMoved(touches)
    }
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches , with: event)
        onTouchesEnded(touches)
    }
}
// MARK: UIScrollViewDelegate
extension OMScrollableChart: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isTracking {
        }
        rules.ruleLeadingAnchor?.constant = CGFloat(contentOffset.x)
        self.isScrolling = true
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didScrollingFinished(scrollView: scrollView)
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        } else {
            didScrollingFinished(scrollView: scrollView)
        }
    }
    func didScrollingFinished(scrollView: UIScrollView) {
        Log.d("Scrolling \(String(describing: scrollView.classForCoder)) was Finished")
        self.isScrolling = false
    }
}
