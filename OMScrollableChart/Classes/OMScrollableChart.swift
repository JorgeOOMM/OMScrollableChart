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

struct ScrollChartTheme {
    static let pointSize: CGSize = CGSize(width: 12, height: 12)
    static let pointsColor: UIColor = UIColor.darkGreyBlueTwo
    static let selectedPointSize: CGSize =  CGSize(width: 15, height: 15)
    static let selectedPointColor: UIColor = UIColor.greyishBlue
    static let currentPointSize: CGSize = CGSize(width: 11, height: 11)
    static let currentPointColor: UIColor = UIColor.paleGrey
    static let polylineColor: UIColor = UIColor.green
    static let polylineLineWidth: CGFloat = 8
    static let segmentsColor: UIColor = UIColor.greyishBlue
    static let segmentLineWidth: CGFloat  = 4
    
}

struct ScrollChartConfiguration {
    static let maxNumberOfRenders: Int = 10
}


var animationTimingTable: [AnimationTiming] = [
    .oneShot,
    .oneShot,
    .oneShot,
    .none,
    .none,
    .none,
    .none
]

extension OMScrollableChart: RenderableDelegateProtocol, RenderableProtocol {
    func animateLayers(chart: OMScrollableChart,
                       renderIndex: Int,
                       layerIndex: Int,
                       layer: OMGradientShapeClipLayer) -> CAAnimation? {
        switch Renders(rawValue: renderIndex) {
        case .points, .selectedPoint, .currentPoint, .segments:
            return nil
        case .polyline:
            guard let polylinePath = chart.polylinePath,
                    let layerToRide = chart.renderSelectedPointsLayer else {
                return nil
            }
            // Ride the selected point along the polyline path
            return chart.animateLayerPathRideToPoint( polylinePath,
                                                      layerToRide: layerToRide,
                                                      pointIndex: chart.numberOfSections,
                                                      duration: 10)
            
        case .bar1:
            let pathStart = pathsToAnimate[renderIndex - 3][layerIndex]
            return chart.animateLayerPath( layer,
                                           pathStart: pathStart,
                                           pathEnd: UIBezierPath( cgPath: layer.path!))
        case .bar2:
            let pathStart = pathsToAnimate[renderIndex - 3][layerIndex]
            return chart.animateLayerPath( layer,
                                           pathStart: pathStart,
                                           pathEnd: UIBezierPath( cgPath: layer.path!) )
            
        default:
            return nil
        }
    }
    var numberOfRenders: Int {
        return RendersBase
    }
    func dataLayers(chart: OMScrollableChart, renderIndex: Int, section: Int, points: [CGPoint]) -> [OMGradientShapeClipLayer] {
        switch Renders(rawValue:  renderIndex) {
            //        case 0:
            //            let layers = chart.updatePolylineLayer(lineWidth: 4,
            //                                                   color: .greyishBlue)
            //            layers.forEach({$0.name = "polyline"}) //debug
            //            return layers
            //        case 1:
            //            let layers = chart.createPointsLayers(points,
            //                                                  size: CGSize(width: 8, height: 8),
            //                                                  color: .greyishBlue)
            //            layers.forEach({$0.name = "point"})  //debug
            //            return layers
            //        case 2:
            ////            if let point = chart.maxPoint(renderIndex: renderIndex) {
            ////                let layer = chart.createPointLayer(point,
            ////                                                   size: CGSize(width: 12, height: 12),
            ////                                                   color: .darkGreyBlueTwo)
            ////                layer.name = "selectedPoint"  //debug
            ////                return [layer]
            ////            }
            ////            return []
            //            return []
        case .bar1:
            let layers =  chart.createRectangleLayers(points, columnIndex: 1, count: 6,
                                                      color: .black)
            layers.forEach({$0.name = "bar income"})  //debug
            self.pathsToAnimate.insert(
                chart.createInverseRectanglePaths(points, columnIndex: 1, count: 6),
                at: 0)
            return layers
        case .bar2:
            
            let layers =  chart.createRectangleLayers(points, columnIndex: 4, count: 6,
                                                      color: .green)
            layers.forEach({$0.name = "bar outcome"})  //debug
            self.pathsToAnimate.insert(
                chart.createInverseRectanglePaths(points, columnIndex: 4, count: 6),
                at: 1)
            return layers
            
        default:
            return []
        }
    }

    func queryAnimation(chart: OMScrollableChart, renderIndex: Int) -> AnimationTiming {
        return animationTimingTable[renderIndex]
    }

    func didSelectDataIndex(chart: OMScrollableChart, renderIndex: Int, dataIndex: Int, layer: CALayer) {
        switch Renders(rawValue: renderIndex) {
        case .polyline:
            chart.renderSelectedPointsLayer?.position =  layer.position
        case .points:
            break
        case .segments:
            break
        case .selectedPoint:
            break
        case .currentPoint:
            break
        case .bar1:
            break
        case .bar2:
            break
        case .none:
            break
        }
    }
    func animationDidEnded(chart: OMScrollableChart, renderIndex: Int, animation: CAAnimation) {
        switch Renders(rawValue: renderIndex) {
        case .polyline:
            break
        case .points:
            break
        case .segments:
            animationTimingTable[renderIndex] = .none
        case .selectedPoint:
            break
        case .currentPoint:
            break
        case .bar1:
            break
        case .bar2:
            break
        case .none:
            break
        }
    }
    func layerOpacity(chart: OMScrollableChart, renderIndex: Int) -> CGFloat {
        switch renderIndex {
        case 0: return 1
        case 1: return 1
        case 2: return 1
        case 3: return 1
        case 4: return 1
        case 5: return 0
        case 6: return 0
        default: return 0
        }
    }
}

@objcMembers
public class OMScrollableChart: UIScrollView, ChartProtocol, CAAnimationDelegate {
    private var pointsLayer: OMGradientShapeClipLayer =  OMGradientShapeClipLayer()
    var polylineLayer: OMGradientShapeClipLayer =  OMGradientShapeClipLayer()
    var dashLineLayers = [OMGradientShapeClipLayer]()
    var rootRule: RuleProtocol?
    var footerRule: RuleProtocol?
    var topRule: RuleProtocol?
    var rules = [RuleProtocol]() // todo
    weak var dataSource: DataSourceProtocol?
    weak var renderSource: RenderableProtocol?
    weak var renderDelegate: RenderableDelegateProtocol?
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
    var layoutCache = [String: Any]()
    var isLayoutCacheActive: Bool = true
    var cacheTrackingLayout: Int = 0
    var isScrollAnimation: Bool = false
    var isScrollAnimnationDone: Bool = false
    let scrollingProgressDuration: TimeInterval = 1.2
    
//    var isAnimatePointsClearOpacity: Bool = false
//    var isAnimatePointsClearOpacityDone: Bool = false
    var rideAnim: CAAnimation? = nil
    var layerToRide: CALayer?
    var ridePath: Path?
    var currentLocale: Locale = Locale(identifier: "es_ES")
    
    // MARK: - Tooltip -
    var tooltip: OMBubbleTextView = OMBubbleTextView()
    var scaledPointsGenerator =
    [InlineScaledPointsGenerator](repeating: InlineScaledPointsGenerator([], size: .zero, insets: UIEdgeInsets(top: 0, left: 0,bottom: 0,right: 0)),
                            count: ScrollChartConfiguration.maxNumberOfRenders)
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
    
    // MARK: - DashLines -
    public lazy var dashlines: OMScrollableChartDashLines = {
        let lines = OMScrollableChartDashLines(contentView: contentView)
        return lines
    }()
    // MARK: - Rules -
    public lazy var ruleManager: OMScrollableChartRules = {
        let rule = OMScrollableChartRules(chart: self)
        return rule
    }()
    
    // Content view
    lazy var contentView: UIView =  {
        let lazyContentView = UIView(frame: self.bounds)
        self.addSubview(lazyContentView)
        return lazyContentView
    }()
    
    // Scaled generator
    var tooltipBorderColor = UIColor.black.cgColor {
        didSet {
            tooltip.layer.borderColor = tooltipBorderColor
        }
    }
    var tooltipBorderWidth: CGFloat = 0.0 {
        didSet {
            tooltip.layer.borderWidth = tooltipBorderWidth
        }
    }
    var toolTipBackgroundColor: UIColor = UIColor.clear {
        didSet {
            tooltip.backgroundColor = toolTipBackgroundColor
        }
    }
    var tooltipFont = UIFont.systemFont(ofSize: 12, weight: .light) {
        didSet {
            tooltip.font = tooltipFont
        }
    }
    var tooltipAlpha: CGFloat = 0 {
        didSet {
            tooltip.alpha = tooltipAlpha
        }
    }
    // MARK: - Data Bounds -
    // Number of sections per page
    // For example: mouths : 6
    var numberOfSectionsPerPage: Int {
        return dataSource?.numberOfSectionsPerPage(chart: self) ?? 1
    }
    // Number total of sections
    var numberOfSections: Int {         // Total
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
            updateLayoutForceReload()
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
    
    var dashPattern: [CGFloat] = [1, 2] {
        didSet {
            dashLineLayers.forEach({($0).lineDashPattern = dashPattern.map{NSNumber(value: Float($0))}})
        }
    }
    var dashLineWidth: CGFloat = 0.5 {
        didSet {
            dashLineLayers.forEach({$0.lineWidth = dashLineWidth})
        }
    }
    var dashLineColor = UIColor.black.withAlphaComponent(0.8).cgColor {
        didSet {
            dashLineLayers.forEach({$0.strokeColor = dashLineColor})
        }
    }
    // MARK: - Rules -
    
    var rulesMarks: [Float] {
        return ruleManager.rulesMarks.sorted(by: { !($0 > $1) })
    }
    
    // MARK: - Footer -
    var decorationFooterRuleColor = UIColor.black {
        didSet {
            ruleManager.footerRule?.decorationColor = decorationFooterRuleColor
        }
    }
    
    // MARK: - Font color -
    var fontFooterRuleColor = UIColor.darkGreyBlueTwo {
        didSet {
            ruleManager.footerRule?.fontColor = fontFooterRuleColor
        }
    }
    
    var fontRootRuleColor = UIColor.black {
        didSet {
            ruleManager.rootRule?.fontColor = fontRootRuleColor
        }
    }
    
    var fontTopRuleColor = UIColor.black {
        didSet {
            ruleManager.topRule?.fontColor = fontTopRuleColor
        }
    }
    
    var footerRuleBackgroundColor = UIColor.black {
        didSet {
            ruleManager.footerRule?.backgroundColor = footerRuleBackgroundColor
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
            print("contentSize is now \(object.contentSize) \(object.bounds)")
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
    func setupView() {
        registerNotifications()
        // Setup the UIScrollView
        delegate = self
        if #available(iOS 11, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
        // configure
        ruleManager.configure(with: fontRootRuleColor,
                              and: fontFooterRuleColor)
        
        setupTooltip()
    }
    
    func contentSizeHeight() -> CGFloat {
        return contentSize.height - ruleManager.footerViewHeight
    }
    
    func updateContentSize() {
        layoutIfNeeded()
        let newValue = CGSize(width: bounds.width * CGFloat(numberOfPages),
                              height: bounds.height)
        if contentSize != newValue {
            contentSize = newValue
            contentView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: contentSize.width,
                                       height: contentSizeHeight())
            
            flowDelegate?.contentSizeChanged(contentSize: newValue)
        }
        updateLayout()
    }
    
    func dataSourceForRenderDataPoints(_ dataSource: DataSourceProtocol) -> [[Float]] {
        var dataPointsRenderNewDataPoints = [[Float]]()
        if let render = self.renderSource, render.numberOfRenders > 0  {
            // get the layers.
            for index in 0..<render.numberOfRenders {
                let dataPoints = dataSource.dataPoints(chart: self,
                                                       renderIndex: index,
                                                       section: 0)
                let dataPointsChanged = renderDataPoints.first?.hashValue != dataPoints.hashValue
                if dataPointsChanged {
                    scaledPointsGenerator[index].data = dataPoints
                    flowDelegate?.dataPointsChanged(dataPoints: dataPoints, for: index)
                }
                
                dataPointsRenderNewDataPoints.insert(dataPoints, at: index)
            }
        } else {
            // Only exist one render.
            let dataPoints = dataSource.dataPoints(chart: self,
                                                   renderIndex: 0,
                                                   section: 0)
            let dataPointsChanged = renderDataPoints.first?.hashValue != dataPoints.hashValue
            if dataPointsChanged {
                scaledPointsGenerator.first?.data = dataPoints
                flowDelegate?.dataPointsChanged(dataPoints: dataPoints, for: 0)
            }
            dataPointsRenderNewDataPoints.insert(dataPoints, at: 0)
        }
        return dataPointsRenderNewDataPoints
    }
    
    var flowDelegate: RuleDelegateProtocol? = OMScrollableChartRuleFlow()
    
    func updateDataSourceData() -> Bool {
        if let dataSource = dataSource {
            // get the data points
            renderDataPoints = dataSourceForRenderDataPoints(dataSource)
            if let footerRule = self.footerRule as? OMScrollableChartRuleFooter {
                if let texts = dataSource.footerSectionsText(chart: self) {
                    if texts != footerRule.footerSectionsText {
                        footerRule.footerSectionsText = texts
                        flowDelegate?.footerSectionsTextChanged(texts: texts)
                    }
                }
            }
            let oldNumberOfPages = numberOfPages
            let newNumberOfPages = dataSource.numberOfPages(chart: self)
            if oldNumberOfPages != newNumberOfPages {
                //print("numberOfPagesChanged: \(oldNumberOfPages) -> \(newNumberOfPages)")
                self.numberOfPages = newNumberOfPages
                flowDelegate?.numberOfPagesChanged(pages: newNumberOfPages)
                return true
            }
        }
        return false
    }
}
// MARK: - Points generator
extension OMScrollableChart {
    func rawPoints(_ data: [Float], size: CGSize) -> [CGPoint] {
        if let generator = polylineGenerator {
            generator.updateRangeLimits(data)
            return generator.makePoints(data: data, size: size)
        }
        return []
    }
    func averagedPoints( data: [Float], size: CGSize, elementsToAverage: Int) -> [CGPoint]? {
        guard let generator = scaledPointsGenerator.first else {
            return nil
        }
        if elementsToAverage > 0 {
            var result: Float = 0
            let chunked = data.chunked(into: elementsToAverage)
            let averagedData: [Float] = chunked.map {
                vDSP_meanv($0, 1, &result, vDSP_Length($0.count));
                return result
            }
            return generator.makePoints(data: averagedData, size: size)
        }
        return nil
    }
    func simplifiedPoints( points: [CGPoint], tolerance: CGFloat) -> [CGPoint]? {
        guard tolerance > 0, points.isEmpty == false else {
            return nil
        }
        return  PolylineSimplify.simplify(points, tolerance: Float(tolerance))
    }
}

extension OMScrollableChart {
    
    public typealias ChartData = (points: [CGPoint], data: [Float])
    
    var allPointsRender: [CGPoint] { return  pointsRender.flatMap{$0}}
    var allDataPointsRender: [Float] { return  renderDataPoints.flatMap{$0}}
    
    var polylineGenerator: InlineScaledPointsGenerator? {
        return scaledPointsGenerator[Renders.polyline.rawValue]
    }
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
    
    private func removeAllLayers() {
        self.renderLayers.forEach{$0.forEach{$0.removeFromSuperlayer()}}
        self.renderType = []
        self.renderLayers = []
    }
    func regenerateRendersLayers(_ numberOfRenders: Int, _ dataSource: DataSourceProtocol) {
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
        for (renderIndex, layer) in allRendersLayers.enumerated() {
            // Insert the render layers
            self.contentView.layer.addSublayer(layer)
        }
    }
    
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
    
    
    /// layoutRenders
    ///
    /// - Parameters:
    ///   - numberOfRenders: numberOfRenders
    func layoutRenders(_ numberOfRenders: Int) {
        guard let dataSource = dataSource else { return }
        guard let renderDelegate = renderDelegate else { return }
        regenerateRendersLayers(numberOfRenders, dataSource)
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
    
    fileprivate func regenerateLayerTree(_ ignoreLayout: Bool) {
        print("Regenerating the layer tree for: \(self.contentView.bounds) \(ignoreLayout)")
        removeAllLayers()
        //                addLeadingRuleIfNeeded(rootRule, view: self)
        //                addFooterRuleIfNeeded(footerRule)
        //                rulebottomAnchor?.isActive = true
        
        if contentView.superview != nil {
            ruleManager.configureRules(using: contentView)
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
            scrollingProgressAnimatingToPage(scrollingProgressDuration,
                                             page: 1)
        } else {
            // Only animate if the points if the render its visible.
//            if rendersIsVisible(renderIndex: Renders.points.rawValue) {
//                animatePointsClearOpacity()
//            }
        }
    }
    
    /// Update the chart layout
    ///
    /// - Parameter forceLayout: Bool
    private func updateLayout( ignoreLayout: Bool = false) {
        Log.v("updateLayout for render points blounded at frame \(self.frame) [IGNORE:\(ignoreLayout)]")
        // If we need to force layout, we must ignore the layoput cache.
        if ignoreLayout == false {
            if isLayoutCacheActive {
                let flatPointsToRender = pointsRender.flatMap({$0})
                if flatPointsToRender.isEmpty == false {
                    let frameHash  = self.frame.hashValue
                    let pointsHash = flatPointsToRender.hashValue
                    let dictKey = "\(frameHash ^ pointsHash)"
                    if (layoutCache[dictKey] as? [[CGPoint]]) != nil {
                        Log.v("LCACHE] cache hit \(dictKey)")
                        cacheTrackingLayout += 1
                        setNeedsDisplay()
                        return
                    }
                    Log.v("LCACHE] cache miss \(dictKey)")
                    cacheTrackingLayout = 0
                    layoutCache.updateValue(pointsRender,
                                            forKey: dictKey)
                }
            }
        }
        // Create the points from the discrete data using the renders
        if allDataPointsRender.isEmpty == false {
            Log.v("\(CALayer.isAnimatingLayers) animations running")
            if CALayer.isAnimatingLayers <= 1  || ignoreLayout {
                regenerateLayerTree(ignoreLayout)
            }
        }
    }
    func updateLayoutForceReload() {
        self.updateLayout(ignoreLayout: true)
    }
    
    /// Create the subviews layout chart for the current frame
    ///
    private func layoutSubviewsForFrame() {
        let updated = self.updateDataSourceData()
        Log.v("updateDataSourceData() \(updated)")
        if updated {
            self.updateLayoutForceReload()
        }
    }
}

// MARK: - overrides
extension OMScrollableChart {
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupView()
        self.renderDelegate = self
        self.renderSource = self
        self.clearsContextBeforeDrawing = true
    }
    public override var contentOffset: CGPoint {
        get {
            return super.contentOffset
        }
        set(newValue) {
            if contentOffset != newValue {
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
        updateRendersOpacity()
    }
    public override func layoutSubviews() {
        self.backgroundColor = .clear
        super.layoutSubviews()
        if oldFrame != self.frame {
            self.oldFrame = self.frame
            flowDelegate?.frameChanged(frame: frame)
            layoutSubviewsForFrame()
        } else {
            updateRendersOpacity()
        }
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

extension OMScrollableChart: UIScrollViewDelegate {
    // MARK: Scroll Delegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isTracking {
            // self.setNeedsDisplay()
        }
        ruleManager.ruleLeadingAnchor?.constant = CGFloat(contentOffset.x)
    }
    //  scrollViewDidEndDragging - The scroll view sends this message when
    //    the user’s finger touches up after dragging content.
    //    The decelerating property of UIScrollView controls deceleration.
    //
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    //    scrollViewWillBeginDecelerating - The scroll view calls
    //    this method as the user’s finger touches up as it is
    //    moving during a scrolling operation; the scroll view will continue
    //    to move a short distance afterwards. The decelerating property of
    //    UIScrollView controls deceleration
    //
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        //self.layoutIfNeeded()
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didScrollingFinished(scrollView: scrollView)
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            //didEndDecelerating will be called for sure
            return
        } else {
            didScrollingFinished(scrollView: scrollView)
        }
    }
    func didScrollingFinished(scrollView: UIScrollView) {
        //GCLog.print("Scrolling \(String(describing: scrollView.classForCoder)) was Finished", .trace)
    }
}
