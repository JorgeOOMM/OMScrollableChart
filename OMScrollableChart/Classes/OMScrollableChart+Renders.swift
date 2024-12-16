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

/*
 La idea es que el usuario facilmente pueda crear representacion
 para sus datos.
 
 El motor usa como herramientas de construccion los diferentes `renders` que se le proporcione,
 Los 'renders´ proporcionan layers al motor cuando quieran representa datos, animaciones
 cuando se quiera animar los datos representados...etc
 
 Yo proporcionno los 6 primeros. Llamados: 'legacy renders´
 
 polyline:  Mantiene una linea uniendo todos los puntos de información de la representación de los datos, la            
 linea por defecto está interpolada usando 'Catmull-Rom splines`, aunque es completamente
 configurable.
 puntos  :  Representa cada punto de información de la representación de los datos.
 punto seleccionado
 punto actual
 segmento de seccion
 */


extension UIColor {
    var colorMap: [UIColor] {
        return [self.lighterColor(percent: 0.0),
                self.lighterColor(percent: 0.1),
                self.lighterColor(percent: 0.2),
                self.lighterColor(percent: 0.3),
                self.lighterColor(percent: 0.4),
                self.darkerColor(percent: 0.4),
                self.darkerColor(percent: 0.3),
                self.darkerColor(percent: 0.2),
                self.darkerColor(percent: 0.1),
                self.darkerColor(percent: 0.0)]
    }
}


let layersOnTopBaseZPosition: CGFloat = 10000
let layersUnderTopBaseZPosition: CGFloat = 1000
let layersUnderUnderBaseZPosition: CGFloat = 100
//
//extension OMScrollableChart {
//    func makeColorMap( _ color: UIColor, _ data: [Float], _ minimun: Float, _ maximun: Float, _ colorMapLen: Int) -> [UIColor]{
//        let colorsSegmentBorder = data.compactMap {
//            let result = linlin(val: Double($0),
//                                inMin: Double(minimun),
//                                inMax: Double(maximun),
//                                outMin: 0,
//                                outMax: Double(colorMapLen - 1))
//            return color.colorMap[lrintl(result)].withAlphaComponent(result / Double(colorMapLen - 1))
//        }
//        return colorsSegmentBorder
//    }
//    
//    private func renderDefaultLayers(_ renderIndex: Int, points: [CGPoint], data: [Float]? = nil) -> [OMGradientShapeClipLayer] {
//        switch Renders(rawValue: renderIndex) {
//        case .polyline:
//            let layers = updatePolylineLayer(lineWidth: ScrollChartTheme.polylineLineWidth,
//                                             color: ScrollChartTheme.polylineColor)
//#if DEBUG
//            assert(layers.count == 1, "Polyline must have only one layer")
//            layers.first?.name = "polyline"
//#endif
//            return layers
//        case .segments:
//            guard let subPaths = self.polylinePath?.cgPath.subpaths, subPaths.count > 0 else {
//                Log.e("Empty polyline subpaths.")
//                return []
//            }
//       
//            guard let data = data, let maximun = data.max(), let minimun = data.min() else {
//                return []
//            }
//            let layers = createSegmentLayers(subPaths,
//                                             ScrollChartTheme.segmentLineWidth,
//                                             makeColorMap( ScrollChartTheme.segmentsColor, data, minimun, maximun, 10))
//            
//            let layersBorder = createSegmentLayers(subPaths,
//                                              ScrollChartTheme.segmentBorderLineWidth,
//                                             makeColorMap( ScrollChartTheme.segmentsBorderColor, data, minimun, maximun, 10))
//            
//#if DEBUG
//            layersBorder.enumerated().forEach { $1.name = "line segment border \($0)" } // debug
//#endif
//            layers.enumerated().forEach { $1.zPosition = layersUnderUnderBaseZPosition }
//#if DEBUG
//            layers.enumerated().forEach { $1.name = "line segment \($0)" } // debug
//#endif
//            return layers + layersBorder
//        case .points:
//            let layers = createPointsLayers(points,
//                                            size: ScrollChartTheme.pointSize,
//                                            color: ScrollChartTheme.pointsColor)
//            
//            for (index, layer) in layers.enumerated() {
//                // Keep point on top of superlayer
//                layer.zPosition  = layersUnderTopBaseZPosition + CGFloat(index)
//#if DEBUG
//                layer.name = "point \(index)"
//#endif
//            }
//            return layers
//        case .selectedPoint:
//            if let point = maxPoint(in: renderIndex) {
//                let layer = createPointLayer(point,
//                                             size: ScrollChartTheme.selectedPointSize,
//                                             color: ScrollChartTheme.selectedPointColor)
//#if DEBUG
//                layer.name = "selectedPoint"
//#endif
//                // Keep point on top of superlayer
//                layer.zPosition  = layersOnTopBaseZPosition
//                return [layer]
//            }
//        case .currentPoint:
//            if let point = maxPoint(in: renderIndex) {
//                let layer = createPointLayer(point,
//                                             size: ScrollChartTheme.currentPointSize,
//                                             color: ScrollChartTheme.currentPointColor)
//#if DEBUG
//                layer.name = "currentPoint"
//#endif
//                layer.zPosition  = layersOnTopBaseZPosition
//                return [layer]
//            }
//        default:
//            return []
//        }
//        return []
//    }
//    var polylinePath: UIBezierPath? {
//        guard  let polylinePoints = polylinePoints,
//               let polylinePath = polylineInterpolation.asPath(points: polylinePoints) else {
//            Log.e("Unable to get a Path from the polyline points.")
//            return nil
//        }
//        return polylinePath
//    }
//    func updatePolylineLayer( lineWidth: CGFloat,
//                              color: UIColor) -> [OMGradientShapeClipLayer] {
//        guard  let polylinePath = polylinePath else {
//            return []
//        }
//        let polylineLayer: OMGradientShapeClipLayer = OMGradientShapeClipLayer()
//        polylineLayer.path          = polylinePath.cgPath
//        polylineLayer.fillColor     = UIColor.clear.cgColor
//        polylineLayer.strokeColor   = color.withAlphaComponent(0.5).cgColor
//        polylineLayer.lineWidth     = lineWidth
//        polylineLayer.shadowColor   = UIColor.black.cgColor
//        polylineLayer.shadowOffset  = CGSize(width: 0, height: lineWidth * 2)
//        polylineLayer.shadowOpacity = 0.5
//        polylineLayer.shadowRadius  = 6.0
//        polylineLayer.anchorPoint   = .zero
//        polylineLayer.lineCap       = .square
//        polylineLayer.lineJoin      = .round
//        // Update the frame
//        polylineLayer.frame         = contentView.bounds
//        return [polylineLayer]
//    }
//    
//    func createPointsLayers( _ points: [CGPoint], size: CGSize, color: UIColor) -> [OMShapeLayerRadialGradientClipPath] {
//        guard  points.count > 0 else {
//            return []
//        }
//        var layers = [OMShapeLayerRadialGradientClipPath]()
//        for point in points {
//            let circleLayer = createPointLayer(point, size: size, color: color)
//            layers.append(circleLayer)
//        }
//        return layers
//    }
//    
//    private func createPointLayer( _ point: CGPoint, size: CGSize, color: UIColor) -> OMShapeLayerRadialGradientClipPath {
//        let circleLayer = OMShapeLayerRadialGradientClipPath()
//        circleLayer.bounds = CGRect(x: 0,
//                                    y: 0,
//                                    width: size.width,
//                                    height: size.height)
//        let path = UIBezierPath(ovalIn: circleLayer.bounds).cgPath
//        circleLayer.gradientColor   = color
//        circleLayer.path            = path
//        circleLayer.fillColor       = color.cgColor
//        circleLayer.position        = point
//        circleLayer.strokeColor     = nil
//        circleLayer.lineWidth       = 0.5
//        
//        circleLayer.shadowColor     = UIColor.black.cgColor
//        circleLayer.shadowOffset    = pointsLayersShadowOffset
//        circleLayer.shadowOpacity   = 0.7
//        circleLayer.shadowRadius    = 3.0
//        circleLayer.isHidden        = false
//        circleLayer.bounds          = circleLayer.path!.boundingBoxOfPath
//        
//        return circleLayer
//    }
//    
//    func createInverseRectanglePaths( _ points: [CGPoint],
//                                      columnIndex: Int,
//                                      count: Int) -> [UIBezierPath] {
//        var paths =  [UIBezierPath]()
//        for currentPointIndex in 0..<points.count - 1 {
//            let width = abs(points[currentPointIndex].x - points[currentPointIndex+1].x)
//            let widthDivisor = width / CGFloat(count)
//            let originX = points[currentPointIndex].x + (widthDivisor * CGFloat(columnIndex))
//            let point = CGPoint(x: originX, y: points[currentPointIndex].y)
//            let height = contentView.frame.maxY - points[currentPointIndex].y
//            let path = UIBezierPath(
//                rect: CGRect(
//                    x: point.x,
//                    y: point.y + height,
//                    width: width / CGFloat(count),
//                    height: 1)
//            )
//            paths.append(path)
//        }
//        
//        return paths
//    }
//    func createRectangleLayers( _ points: [CGPoint],
//                                columnIndex: Int,
//                                count: Int,
//                                color: UIColor) -> [OMGradientShapeClipLayer] {
//        guard  points.count > 0 else {
//            return []
//        }
//
//        var layers =  [OMGradientShapeClipLayer]()
//        for currentPointIndex in 0..<points.count - 1 {
//            let width = abs(points[currentPointIndex].x - points[currentPointIndex+1].x)
//            let height =  contentView.frame.maxY - points[currentPointIndex].y
//            let widthDivisor = width / CGFloat(count)
//            let originX = points[currentPointIndex].x + (widthDivisor * CGFloat(columnIndex))
//            let point = CGPoint(x: originX, y: points[currentPointIndex].y)
//            let path = UIBezierPath(
//                rect: CGRect(
//                    x: point.x,
//                    y: point.y,
//                    width: width / CGFloat(count),
//                    height: height) //self.frame.maxY - points[currentPointIndex].y - footerViewHeight)
//            )
//            let rectangleLayer = OMShapeLayerLinearGradientClipPath()
//            rectangleLayer.gardientColor   = color
//            rectangleLayer.path            = path.cgPath
//            rectangleLayer.fillColor       = color.withAlphaComponent(0.6).cgColor
//            rectangleLayer.position        = point
//            rectangleLayer.strokeColor     = color.cgColor
//            rectangleLayer.lineWidth       = 1
//            rectangleLayer.anchorPoint     = .zero
//            rectangleLayer.shadowColor     = UIColor.black.cgColor
//            rectangleLayer.shadowOffset    = pointsLayersShadowOffset
//            rectangleLayer.shadowOpacity   = 0.7
//            rectangleLayer.shadowRadius    = 3.0
//            rectangleLayer.isHidden        = false
//            rectangleLayer.bounds          = rectangleLayer.path!.boundingBoxOfPath
//            layers.insert(rectangleLayer, at: currentPointIndex)
//        }
//        return layers
//    }
//    fileprivate func addSegmentLayer(_ color: UIColor, _ lineWidth: CGFloat, _ path: UIBezierPath) -> OMGradientShapeClipLayer {
//        let shapeSegmentLayer = OMGradientShapeClipLayer()
////        shapeSegmentLayer.strokeColor   = color.cgColor
//        shapeSegmentLayer.strokeColor   = color.withAlphaComponent(0.8).cgColor
//        shapeSegmentLayer.lineWidth     = lineWidth
//        shapeSegmentLayer.path          = path.cgPath
//        let box = path.bounds
//        
//        shapeSegmentLayer.position      = box.origin
//        shapeSegmentLayer.fillColor     = color.darker.withAlphaComponent(0.12).cgColor
////        shapeSegmentLayer.fillColor     = color.cgColor
//        shapeSegmentLayer.bounds        = box //.insetBy(dx: -(lineWidth), dy: -(lineWidth))
//        shapeSegmentLayer.anchorPoint   = .zero
//        shapeSegmentLayer.lineCap       = .square
//        shapeSegmentLayer.lineJoin      = .round
//        shapeSegmentLayer.opacity       = 1.0
//        
////        shapeSegmentLayer.setGlow( with: color)
//        shapeSegmentLayer.setNeedsLayout()
//        
//        return shapeSegmentLayer
//    }
//    ///
//    /// createSegmentLayers
//    ///
//    /// - Parameters:
//    ///   - segmentsPaths: [UIBezierPath]
//    ///   - lineWidth: lineWidth
//    ///   - color: UIColor
//    /// - Returns: [OMGradientShapeClipLayer]
//    ///
//    ///
//    func createSegmentLayers(_ segmentsPaths: [UIBezierPath],
//                             _ lineWidth: CGFloat,
//                             _ colors: [UIColor]) -> [OMGradientShapeClipLayer] {
//        var layers = [OMGradientShapeClipLayer]()
//        for (idx, path) in segmentsPaths.enumerated() {
//            let color = colors[idx % colors.count]
//            let shapeSegmentLayer = addSegmentLayer(color, lineWidth, path)
//            layers.append(shapeSegmentLayer)
//        }
//        return layers
//    }
//}
//
// Query the data layers to the delegate
//
extension OMScrollableChart {
//        
//    func makeSimplified(_ data: [Float], _ renderIndex: Int, _ boundsSize: CGSize, _ dataSource: DataSourceProtocol) {
//        guard let renderDelegate = renderDelegate,let pointsGenerator = self.pointsGeneratorModel else {
//            return
//        }
//        
//        let discretePoints = pointsGenerator.rawPoints(data, size: boundsSize)
//        
//        if discretePoints.count > 0 {
//            let chartData = (discretePoints, data)
//            let simplifiedPoints =  pointsGenerator.simplifiedPoints( points: discretePoints,
//                                                                tolerance: simplifiedTolerance)
//            if simplifiedPoints.count > 0 {
//                self.simplifiedData.insert(chartData, at: renderIndex)
//                self.pointsRender.insert(simplifiedPoints, at: renderIndex)
//                var layers = renderDelegate.dataLayers(chart: self,
//                                                   renderIndex: renderIndex,
//                                                   section: 0, points: simplifiedPoints)
//                // accumulate layers
//                if layers.isEmpty {
//                    layers = renderDefaultLayers(renderIndex,
//                                                 points: simplifiedPoints,
//                                                 data: data)
//                }
//                
//                self.renderLayers.insert(layers, at: renderIndex)
//            }
//        }
//    }
//    
//    func makeAverage(_ data: [Float], _ renderIndex: Int,_ boundsSize: CGSize, _ dataSource: DataSourceProtocol) {
//        guard let renderDelegate = renderDelegate, let pointsGenerator = self.pointsGeneratorModel else {
//            return
//        }
//        let averagePoints = pointsGenerator.averagedPoints(data: data,
//                                                    size: boundsSize,
//                                                    elementsToAverage: self.numberOfElementsToAverage)
//        if averagePoints.count > 0 {
//            let chartData = (averagePoints, data)
//            self.averagedData.insert(chartData, at: renderIndex)
//            self.pointsRender.insert(averagePoints, at: renderIndex)
//            var layers = renderDelegate.dataLayers(chart: self,
//                                                   renderIndex: renderIndex,
//                                                   section: 0,
//                                                   points: averagePoints)
//            // accumulate layers
//            if layers.isEmpty {
//                layers = renderDefaultLayers(renderIndex, points: averagePoints, data: data)
//            }
//            // accumulate layers
//            self.renderLayers.insert(layers, at: renderIndex)
//        }
//    }
//    
//    func makeDiscrete(_ data: [Float],
//                      _ renderIndex: Int,
//                      _ boundsSize: CGSize, _ dataSource: DataSourceProtocol) {
//        guard let renderDelegate = renderDelegate, let pointsGenerator = self.pointsGeneratorModel else {
//            return
//        }
//        let points = pointsGenerator.rawPoints(data, size: boundsSize)
//        if points.count > 0 {
//            let chartData = (points, data)
//            self.discreteData.insert(chartData, at: renderIndex)
//            self.pointsRender.insert(points, at: renderIndex)
//            
//            var layers = renderDelegate.dataLayers(chart: self,
//                                               renderIndex: renderIndex,
//                                               section: 0,
//                                               points: points)
//            //  use the private
//            if layers.isEmpty {
//                layers = renderDefaultLayers(renderIndex,
//                                             points: points,
//                                             data: data)
//            }
//            // accumulate layers
//            self.renderLayers.insert(layers, at: renderIndex)
//        }
//    }
//
//    // Lineal Regression
//    private func linregressPoints(data: ChartData, size: CGSize, numberOfElements: Int, renderIndex: Int) -> ChartData {
//        let originalDataIndex: [Float] = data.points.enumerated().map { Float($0.offset) }
//        // Create the regression function for current data
//        let linFunction: (slope: Float, intercept: Float) = Stadistics.linregress(originalDataIndex, data.data)
//        var resulLinregress: [Float] = [Float].init(repeating: 0, count: numberOfElements)
//        for index in 0...numberOfElements - 1 {
//            resulLinregress[index] = linFunction.slope * Float(originalDataIndex.count + index) + linFunction.intercept
//        }
//        // add the new points
//        let newData = data.data + resulLinregress
//        let newPoints = self.pointsGeneratorModel?.pointScaler.makePoints(data: newData, size: size)
//        return (newPoints ?? [], newData)
//    }
//    
//    private func makeLinregress(_ data: [Float],
//                                _ renderIndex: Int,
//                                _ boundsSize: CGSize,
//                                _ dataSource: DataSourceProtocol) {
//        guard let renderDelegate = renderDelegate, let pointsGenerator = self.pointsGeneratorModel else {
//            return
//        }
//        let points = pointsGenerator.rawPoints(data, size: boundsSize)
//        if points.count > 0 {
//            let chartData = (points, data)
//            let linregressData = linregressPoints(data: chartData,
//                                                  size: boundsSize,
//                                                  numberOfElements: self.numberOfRegressValues,
//                                                  renderIndex: renderIndex)
//            self.linregressData.insert(linregressData, at: renderIndex)
//            self.pointsRender.insert(linregressData.0, at: renderIndex)
//            var layers = renderDelegate.dataLayers(chart: self,
//                                               renderIndex: renderIndex,
//                                               section: 0,
//                                               points: linregressData.0)
//            // accumulate layers
//            if layers.isEmpty {
//                layers = renderDefaultLayers(renderIndex,
//                                             points: linregressData.0,
//                                             data: linregressData.data)
//            }
//            
//            // accumulate layers
//            self.renderLayers.insert(layers, at: renderIndex)
//        }
//    }
    
    func regressBondsSize(_ renderIndex: Int) -> CGSize {
        let size = contentView.bounds.size
        let numOfPoints = CGFloat(self.renderDataPoints[renderIndex].count)
        let regressWidth = (self.sectionWidth * CGFloat(self.numberOfRegressValues))
        let width = numOfPoints * self.sectionWidth + regressWidth
        return  CGSize(width: width,
                       height: size.height)
    }
    
    func discreteBondsSize(_ renderIndex: Int) -> CGSize {
        let size = contentView.bounds.size
        return CGSize(width: CGFloat(self.renderDataPoints[renderIndex].count) * self.sectionWidth, height: size.height)
    }
    
    /// renderLayers
    /// 
    /// - Parameters:
    ///   - renderIndex: render index
    ///   - renderAs: RenderData
    func renderLayers(_ renderIndex: Int, renderAs: RenderType) {
        let currentRenderData = renderDataPoints[renderIndex]
        switch renderAs {
        case .simplified(let value):
            self.renderLayersAndPoints?.makeSimplified(currentRenderData, renderIndex, discreteBondsSize(renderIndex), value)
        case .averaged(let value):
            self.renderLayersAndPoints?.makeAverage(currentRenderData, renderIndex, discreteBondsSize(renderIndex), value)
        case .discrete:
            self.renderLayersAndPoints?.makeDiscrete(currentRenderData, renderIndex, discreteBondsSize(renderIndex))
        case .linregress(let value):
            self.renderLayersAndPoints?.makeLinregress(currentRenderData, renderIndex, regressBondsSize(renderIndex), value)
        }
        self.renderType.insert(renderAs, at: renderIndex)
    }
}
