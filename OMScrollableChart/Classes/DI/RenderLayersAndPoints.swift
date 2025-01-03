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
import Accelerate
// MARK: - RenderLayersAndPointsProtocol
class RenderLayersAndPoints: RenderLayersAndPointsProtocol {
    var pointsGeneratorModel: PointsGeneratorModelProtocol
    var layerBuilder: LayerBuilderAndAnimatorProtocol?
    var frame: CGRect
    required init(_ frame: CGRect, _ pointsGeneratorModel: PointsGeneratorModelProtocol) {
        self.pointsGeneratorModel = pointsGeneratorModel
        self.frame = frame
    }
    var polylineInterpolation: PolyLineInterpolation = .catmullRom(0.5)
    var polylinePath: UIBezierPath? {
        let polylinePoints =  pointsRender[Renders.polyline.rawValue]
        guard let polylinePath = polylineInterpolation.asPath(points: polylinePoints) else {
            Log.e("Unable to get a Path from the polyline points.")
            return nil
        }
        return polylinePath
    }
    var renderLayers: [[OMGradientShapeClipLayer]] = []
    var pointsRender: [[CGPoint]] = []
    var opaqueLayers: [CAShapeLayer] {
        return allRendersLayers.filter({$0.opacity == 1.0})
    }
    var transparentLayers: [CAShapeLayer] {
        return allRendersLayers.filter({$0.opacity == 0})
    }
    var allRendersLayers: [CAShapeLayer]  {
        return renderLayers.flatMap({$0})
    }
    func minPoint(in renderIndex: Int) -> CGPoint? {
        return pointsRender[renderIndex].max(by: {$0.x > $1.x})
    }
    func maxPoint(in renderIndex: Int) -> CGPoint? {
        return pointsRender[renderIndex].max(by: {$0.x <= $1.x})
    }
    ///
    /// removeLayers
    ///
    func removeLayers() {
        self.renderLayers.forEach{$0.forEach{$0.removeFromSuperlayer()}}
        self.renderLayers = []
    }
    ///
    /// makeColorMap
    ///
    /// - Parameters:
    ///   - color: UIColor
    ///   - data: [Float]
    ///   - minimun: Float
    ///   - maximun: Float
    ///   - colorMapLen: Int
    /// - Returns: [UIColor]
    ///
    func makeColorMap( _ color: UIColor, _ data: [Float], _ minimun: Float, _ maximun: Float, _ colorMapLen: Int) -> [UIColor]{
        let colorsSegmentBorder = data.compactMap {
            let result = linlin(val: Double($0),
                                inMin: Double(minimun),
                                inMax: Double(maximun),
                                outMin: 0,
                                outMax: Double(colorMapLen - 1))
            return color.colorMap[lrintl(result)].withAlphaComponent(result / Double(colorMapLen - 1))
        }
        return colorsSegmentBorder
    }
    ///
    /// defaultLayers
    ///
    /// - Parameters:
    ///   - renderIndex: Int
    ///   - points: [CGPoint]
    ///   - data: [Float]
    /// - Returns:  [OMGradientShapeClipLayer]
    ///
    func defaultLayers(_ renderIndex: Int, points: [CGPoint], data: [Float]? = nil) -> [OMGradientShapeClipLayer] {
        switch Renders(rawValue: renderIndex) {
        case .polyline:
            let layers = createPolylineLayer(lineWidth: ScrollChartTheme.polylineLineWidth,
                                             color: ScrollChartTheme.polylineColor)
#if DEBUG
            assert(layers.count == 1, "Polyline must have only one layer")
            layers.first?.name = "polyline"
#endif
            return layers
        case .segments:
            guard let subPaths = self.polylinePath?.cgPath.subpaths, subPaths.count > 0 else {
                Log.e("Empty polyline subpaths.")
                return []
            }
       
            guard let data = data, let maximun = data.max(), let minimun = data.min() else {
                return []
            }
            let layers = createSegmentLayers(subPaths,
                                             ScrollChartTheme.segmentLineWidth,
                                             makeColorMap( ScrollChartTheme.segmentsColor, data, minimun, maximun, 10))
            
            let layersBorder = createSegmentLayers(subPaths,
                                              ScrollChartTheme.segmentBorderLineWidth,
                                             makeColorMap( ScrollChartTheme.segmentsBorderColor, data, minimun, maximun, 10))
            
#if DEBUG
            layersBorder.enumerated().forEach { $1.name = "line segment border \($0)" } // debug
#endif
            layers.enumerated().forEach { $1.zPosition = layersUnderUnderBaseZPosition }
#if DEBUG
            layers.enumerated().forEach { $1.name = "line segment \($0)" } // debug
#endif
            return layers + layersBorder
        case .points:
            let layers = createPointsLayers(points,
                                            size: ScrollChartTheme.pointSize,
                                            color: ScrollChartTheme.pointsColor)
            
            for (index, layer) in layers.enumerated() {
                // Keep point on top of superlayer
                layer.zPosition  = layersUnderTopBaseZPosition + CGFloat(index)
#if DEBUG
                layer.name = "point \(index)"
#endif
            }
            return layers
        case .selectedPoint:
            if let point = maxPoint(in: renderIndex) {
                let layer = createPoint(point,
                                             size: ScrollChartTheme.selectedPointSize,
                                             color: ScrollChartTheme.selectedPointColor)
#if DEBUG
                layer.name = "selectedPoint"
#endif
                // Keep point on top of superlayer
                layer.zPosition  = layersOnTopBaseZPosition
                return [layer]
            }
        case .currentPoint:
            if let point = maxPoint(in: renderIndex) {
                let layer = createPoint(point,
                                             size: ScrollChartTheme.currentPointSize,
                                             color: ScrollChartTheme.currentPointColor)
#if DEBUG
                layer.name = "currentPoint"
#endif
                layer.zPosition  = layersOnTopBaseZPosition
                return [layer]
            }
        default:
            return []
        }
        return []
    }
    ///
    /// createPolylineLayer
    ///
    /// - Parameters:
    ///   - lineWidth: CGFloat
    ///   - color: UIColor
    /// - Returns: [OMGradientShapeClipLayer]
    ///
    func createPolylineLayer( lineWidth: CGFloat,
                              color: UIColor) -> [OMGradientShapeClipLayer] {
        guard  let polylinePath = polylinePath else {
            return []
        }
        let polylineLayer: OMGradientShapeClipLayer = OMGradientShapeClipLayer()
        polylineLayer.path          = polylinePath.cgPath
        polylineLayer.fillColor     = UIColor.clear.cgColor
        polylineLayer.strokeColor   = color.withAlphaComponent(0.5).cgColor
        polylineLayer.lineWidth     = lineWidth
        polylineLayer.shadowColor   = UIColor.black.cgColor
        polylineLayer.shadowOffset  = CGSize(width: 0, height: lineWidth * 2)
        polylineLayer.shadowOpacity = 0.5
        polylineLayer.shadowRadius  = 6.0
        polylineLayer.anchorPoint   = .zero
        polylineLayer.lineCap       = .square
        polylineLayer.lineJoin      = .round
        // Update the frame
        polylineLayer.frame         = CGRect(origin: .zero, size: self.frame.size)
        return [polylineLayer]
    }
    ///
    /// createPointsLayers
    ///
    /// - Parameters:
    ///   - points: [CGPoint]
    ///   - size: CGSize
    ///   - color: UIColor
    /// - Returns: [OMShapeLayerRadialGradientClipPath]
    ///
    func createPointsLayers( _ points: [CGPoint], size: CGSize, color: UIColor) -> [OMShapeLayerRadialGradientClipPath] {
        guard  points.count > 0 else {
            return []
        }
        var layers = [OMShapeLayerRadialGradientClipPath]()
        for point in points {
            let circleLayer = createPoint(point, size: size, color: color)
            layers.append(circleLayer)
        }
        return layers
    }
    ///
    /// createPoint
    ///
    /// - Parameters:
    ///   - point: [CGPoint]
    ///   - size: CGSize
    ///   - color: UIColor
    /// - Returns: OMShapeLayerRadialGradientClipPath
    ///
    fileprivate func createPoint( _ point: CGPoint, size: CGSize, color: UIColor) -> OMShapeLayerRadialGradientClipPath {
        let circleLayer = OMShapeLayerRadialGradientClipPath()
        circleLayer.bounds = CGRect(x: 0,
                                    y: 0,
                                    width: size.width,
                                    height: size.height)
        let path = UIBezierPath(ovalIn: circleLayer.bounds).cgPath
        circleLayer.gradientColor   = color
        circleLayer.path            = path
        circleLayer.fillColor       = color.cgColor
        circleLayer.position        = point
        circleLayer.strokeColor     = nil
        circleLayer.lineWidth       = 0.5
        
        circleLayer.shadowColor     = UIColor.black.cgColor
        circleLayer.shadowOffset    = ScrollChartTheme.pointsLayersShadowOffset
        circleLayer.shadowOpacity   = 0.7
        circleLayer.shadowRadius    = 3.0
        circleLayer.isHidden        = false
        circleLayer.bounds          = circleLayer.path!.boundingBoxOfPath
        
        return circleLayer
    }
    ///
    /// createInverseRectanglePaths
    ///
    /// - Parameters:
    ///   - points: [CGPoint]
    ///   - columnIndex: Int
    ///   - count: Int
    /// - Returns: [UIBezierPath]
    ///
    func createInverseRectanglePaths( _ points: [CGPoint],
                                      columnIndex: Int,
                                      count: Int) -> [UIBezierPath] {
        var paths =  [UIBezierPath]()
        for currentPointIndex in 0..<points.count - 1 {
            let width = abs(points[currentPointIndex].x - points[currentPointIndex+1].x)
            let widthDivisor = width / CGFloat(count)
            let originX = points[currentPointIndex].x + (widthDivisor * CGFloat(columnIndex))
            let point = CGPoint(x: originX, y: points[currentPointIndex].y)
            let height = self.frame.maxY - points[currentPointIndex].y
            let path = UIBezierPath(
                rect: CGRect(
                    x: point.x,
                    y: point.y + height,
                    width: width / CGFloat(count),
                    height: 1)
            )
            paths.append(path)
        }
        
        return paths
    }
    ///
    /// createRectangleLayers
    ///
    /// - Parameters:
    ///   - points: [CGPoint]
    ///   - columnIndex: Int
    ///   - count: Int
    ///   - color: UIColor
    /// - Returns: [OMGradientShapeClipLayer]
    ///
    func createRectangleLayers( _ points: [CGPoint],
                                columnIndex: Int,
                                count: Int,
                                color: UIColor) -> [OMGradientShapeClipLayer] {
        guard  points.count > 0 else {
            return []
        }
        var layers =  [OMGradientShapeClipLayer]()
        for currentPointIndex in 0..<points.count - 1 {
            let width = abs(points[currentPointIndex].x - points[currentPointIndex+1].x)
            let height =  self.frame.maxY - points[currentPointIndex].y
            let widthDivisor = width / CGFloat(count)
            let originX = points[currentPointIndex].x + (widthDivisor * CGFloat(columnIndex))
            let point = CGPoint(x: originX, y: points[currentPointIndex].y)
            let path = UIBezierPath(
                rect: CGRect(
                    x: point.x,
                    y: point.y,
                    width: width / CGFloat(count),
                    height: height) //self.frame.maxY - points[currentPointIndex].y - footerViewHeight)
            )
            let rectangleLayer = OMShapeLayerLinearGradientClipPath()
            rectangleLayer.gardientColor   = color
            rectangleLayer.path            = path.cgPath
            rectangleLayer.fillColor       = color.withAlphaComponent(0.6).cgColor
            rectangleLayer.position        = point
            rectangleLayer.strokeColor     = color.cgColor
            rectangleLayer.lineWidth       = 1
            rectangleLayer.anchorPoint     = .zero
            rectangleLayer.shadowColor     = UIColor.black.cgColor
            rectangleLayer.shadowOffset    = ScrollChartTheme.pointsLayersShadowOffset
            rectangleLayer.shadowOpacity   = 0.7
            rectangleLayer.shadowRadius    = 3.0
            rectangleLayer.isHidden        = false
            rectangleLayer.bounds          = rectangleLayer.path!.boundingBoxOfPath
            layers.insert(rectangleLayer, at: currentPointIndex)
        }
        return layers
    }
    ///
    /// buildSegment
    /// 
    /// - Parameters:
    ///   - color: UIColor
    ///   - lineWidth: CGFloat
    ///   - path: UIBezierPath
    /// - Returns: OMGradientShapeClipLayer
    ///
    fileprivate func buildSegment(_ color: UIColor, _ lineWidth: CGFloat, _ path: UIBezierPath) -> OMGradientShapeClipLayer {
        let shapeSegmentLayer = OMGradientShapeClipLayer()
//        shapeSegmentLayer.strokeColor   = color.cgColor
        shapeSegmentLayer.strokeColor   = color.withAlphaComponent(0.8).cgColor
        shapeSegmentLayer.lineWidth     = lineWidth
        shapeSegmentLayer.path          = path.cgPath
        let box = path.bounds
        
        shapeSegmentLayer.position      = box.origin
        shapeSegmentLayer.fillColor     = color.darker.withAlphaComponent(0.12).cgColor
//        shapeSegmentLayer.fillColor     = color.cgColor
        shapeSegmentLayer.bounds        = box //.insetBy(dx: -(lineWidth), dy: -(lineWidth))
        shapeSegmentLayer.anchorPoint   = .zero
        shapeSegmentLayer.lineCap       = .square
        shapeSegmentLayer.lineJoin      = .round
        shapeSegmentLayer.opacity       = 1.0
        
        shapeSegmentLayer.setNeedsLayout()
        return shapeSegmentLayer
    }
    ///
    /// createSegmentLayers
    ///
    /// - Parameters:
    ///   - segmentsPaths: [UIBezierPath]
    ///   - lineWidth: lineWidth
    ///   - color: UIColor
    /// - Returns: [OMGradientShapeClipLayer]
    ///
    func createSegmentLayers(_ segmentsPaths: [UIBezierPath],
                             _ lineWidth: CGFloat,
                             _ colors: [UIColor]) -> [OMGradientShapeClipLayer] {
        var layers = [OMGradientShapeClipLayer]()
        for (idx, path) in segmentsPaths.enumerated() {
            let color = colors[idx % colors.count]
            let shapeSegmentLayer = buildSegment(color, lineWidth, path)
            layers.append(shapeSegmentLayer)
        }
        return layers
    }
    /// Reset the data
    func reset() {
        // points and layers
        pointsRender.removeAll()
        renderLayers.removeAll()
    }
    ///
    /// makeSimplified
    ///
    /// - Parameters:
    ///   - data: [Float]
    ///   - renderIndex: Int
    ///   - boundsSize: CGSize
    ///   - simplifiedTolerance: <#simplifiedTolerance description#>
    ///
    func makeSimplified(_ data: [Float], _ renderIndex: Int, _ boundsSize: CGSize, _ simplifiedTolerance: CGFloat = 0) {
        let discretePoints = self.pointsGeneratorModel.rawPoints(data, size: boundsSize)
        if discretePoints.count > 0 {
//            let chartData = (discretePoints, data)
//            self.simplifiedData.insert(chartData, at: renderIndex)
            let simplifiedPoints =  self.pointsGeneratorModel.simplifiedPoints( points: discretePoints,
                                                                tolerance: simplifiedTolerance)
            if simplifiedPoints.count > 0 {
                self.pointsRender.insert(simplifiedPoints, at: renderIndex)
                guard var layers = self.layerBuilder?.buildLayers(for: renderIndex, section: 0, points: simplifiedPoints) else {
                    return
                }
                // accumulate layers
                if layers.isEmpty {
                    layers = defaultLayers(renderIndex,
                                                 points: simplifiedPoints,
                                                 data: data)
                }
                self.renderLayers.insert(layers, at: renderIndex)
            }
        }
    }
    ///
    /// makeAverage
    ///
    /// - Parameters:
    ///   - data: [Float]
    ///   - renderIndex: Int
    ///   - boundsSize: CGSize
    ///   - numberOfElementsToAverage: Int
    ///
    func makeAverage(_ data: [Float], _ renderIndex: Int,_ boundsSize: CGSize, _ numberOfElementsToAverage: Int = 1 ) {
        let averagePoints = self.pointsGeneratorModel.averagedPoints(data: data,
                                                    size: boundsSize,
                                                    elementsToAverage: numberOfElementsToAverage)
        if averagePoints.count > 0 {
//            let chartData = (averagePoints, data)
//            self.averagedData.insert(chartData, at: renderIndex)
            self.pointsRender.insert(averagePoints, at: renderIndex)
            guard var layers = self.layerBuilder?.buildLayers(for: renderIndex, section: 0, points: averagePoints) else {
                return
            }
            // accumulate layers
            if layers.isEmpty {
                layers = defaultLayers(renderIndex, points: averagePoints, data: data)
            }
            // accumulate layers
            self.renderLayers.insert(layers, at: renderIndex)
        }
    }
    ///
    /// makeDiscrete
    ///
    /// - Parameters:
    ///   - data: [Float]
    ///   - renderIndex: Int
    ///   - boundsSize: CGSize
    ///
    func makeDiscrete(_ data: [Float],
                      _ renderIndex: Int,
                      _ boundsSize: CGSize) {
        let points = self.pointsGeneratorModel.rawPoints(data, size: boundsSize)
        if points.count > 0 {
//            let chartData = (points, data)
//            self.discreteData.insert(chartData, at: renderIndex)
            self.pointsRender.insert(points, at: renderIndex)
            guard var layers = self.layerBuilder?.buildLayers(for: renderIndex, section: 0, points: points) else {
                return
            }
            //  use the private
            if layers.isEmpty {
                layers = defaultLayers(renderIndex,
                                             points: points,
                                             data: data)
            }
            // accumulate layers
            self.renderLayers.insert(layers, at: renderIndex)
        }
    }
    ///
    /// Lineal Regression
    ///
    /// - Parameters:
    ///   - data: [Float]
    ///   - points: [CGPoint]
    ///   - size: CGSize
    ///   - numberOfElements: Int
    ///   - renderIndex: Int
    /// - Returns: (points: [CGPoint], data: [Float])
    ///
    private func linregressPoints(data: [Float], points: [CGPoint], size: CGSize, numberOfElements: Int, renderIndex: Int) -> (points: [CGPoint], data: [Float]) {
        let originalDataIndex: [Float] = points.enumerated().map { Float($0.offset) }
        // Create the regression function for current data
        let linFunction: (slope: Float, intercept: Float) = Stadistics.linregress(originalDataIndex, data)
        var resulLinregress: [Float] = [Float].init(repeating: 0, count: numberOfElements)
        for index in 0...numberOfElements - 1 {
            resulLinregress[index] = linFunction.slope * Float(originalDataIndex.count + index) + linFunction.intercept
        }
        // add the new points
        let newData = data + resulLinregress
        let newPoints = self.pointsGeneratorModel.pointScaler.makePoints(data: newData, size: size)
        return (newPoints, newData)
    }
    ///
    /// makeLinregress
    ///
    /// - Parameters:
    ///   - data: [Float]
    ///   - renderIndex: Int
    ///   - boundsSize: CGSIze
    ///   - numberOfRegressValues: Int
    ///
    func makeLinregress(_ data: [Float],
                                _ renderIndex: Int,
                                _ boundsSize: CGSize,
                                _ numberOfRegressValues: Int = 1) {
        let points = self.pointsGeneratorModel.rawPoints(data, size: boundsSize)
        if points.count > 0 {
            let linregressData = linregressPoints(data: data,
                                                  points: points,
                                                  size: boundsSize,
                                                  numberOfElements: numberOfRegressValues,
                                                  renderIndex: renderIndex)
//            let chartData = (points, data)
//            self.linregressData.insert(linregressData, at: renderIndex)
            self.pointsRender.insert(linregressData.points, at: renderIndex)
            guard var layers = self.layerBuilder?.buildLayers(for: renderIndex, section: 0, points: linregressData.points) else {
                return
            }
            // accumulate layers
            if layers.isEmpty {
                layers = defaultLayers(renderIndex,
                                       points: linregressData.points,
                                        data: linregressData.data)
            }
            // accumulate layers
            self.renderLayers.insert(layers, at: renderIndex)
        }
    }
}
