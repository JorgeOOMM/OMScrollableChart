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
import Accelerate
import GUILib
// swiftlint:disable file_length
// swiftlint:disable type_body_length

protocol RenderLayersAndPointsProtocol {
    var pointsGeneratorModel: PointsGeneratorModelProtocol {get set}
    var layerBuilder: LayerBuilderAndAnimatorProtocol? {get set}
    var frame: CGRect  {get set}
    init(_ frame: CGRect,_ pointsGeneratorModel: PointsGeneratorModelProtocol)
    var renderLayers: [[OMGradientShapeClipLayer]] {get set}
    var pointsRender: [[CGPoint]] {get set}
    var polylineInterpolation: PolyLineInterpolation {get set}
    var polylinePath: UIBezierPath?  {get}
    func removeLayers()
    func reset()
    
    func defaultLayers(_ renderIndex: Int, points: [CGPoint], data: [Float]?) -> [OMGradientShapeClipLayer]
    func createSegmentLayers(_ segmentsPaths: [UIBezierPath],_ lineWidth: CGFloat,_ colors: [UIColor]) -> [OMGradientShapeClipLayer]
    func createPointsLayers( _ points: [CGPoint], size: CGSize, color: UIColor) -> [OMShapeLayerRadialGradientClipPath]
    func createPolylineLayer( lineWidth: CGFloat, color: UIColor) -> [OMGradientShapeClipLayer]
    func createRectangleLayers( _ points: [CGPoint], columnIndex: Int, count: Int, color: UIColor) -> [OMGradientShapeClipLayer]
    func createInverseRectanglePaths( _ points: [CGPoint], columnIndex: Int, count: Int) -> [UIBezierPath]
    
    func makeSimplified(_ data: [Float], _ renderIndex: Int, _ boundsSize: CGSize, _ simplifiedTolerance: CGFloat)
    func makeAverage(_ data: [Float], _ renderIndex: Int,_ boundsSize: CGSize, _ numberOfElementsToAverage: Int)
    func makeDiscrete(_ data: [Float], _ renderIndex: Int, _ boundsSize: CGSize)
    func makeLinregress(_ data: [Float], _ renderIndex: Int, _ boundsSize: CGSize, _ numberOfRegressValues: Int)
}

protocol LayerBuilderAndAnimatorProtocol {
    var animatedPaths: [[UIBezierPath]] {get set}
    var renderLayersAndPoints:RenderLayersAndPointsProtocol {get set}
    var layersAnimator: LayersAnimatorProtocol {get set}
    init(renderLayersAndPoints:RenderLayersAndPointsProtocol, layersAnimator: LayersAnimatorProtocol)
    func buildLayers(for renderIndex: Int, section: Int, points: [CGPoint]) -> [OMGradientShapeClipLayer]
    func animateLayers(renderIndex: Int,layerIndex: Int,layer: OMGradientShapeClipLayer) -> CAAnimation?
}

//let percent: CFloat = CFloat(1.0 / Double(self.numberOfSections) * Double(pointIndex))

protocol LayersAnimatorProtocol {
    var ridePathAnimation: CAAnimation? {get set}
    var layerToRide: CALayer?  {get set}
    
    func animateLayerPath( _ shapeLayer: CAShapeLayer,
                           pathStart: UIBezierPath,
                           pathEnd: UIBezierPath,
                           duration: TimeInterval) -> CAAnimation
        
    func pathRideToPointAnimation( cgPath: CGPath,
                                   percent: CFloat,
                                   timingFunction: CAMediaTimingFunction,
                                   duration: TimeInterval) -> CAAnimation?
    func pathRideToPoint( cgPath: CGPath,
                          percent: CFloat,
                          timingFunction: CAMediaTimingFunction ) -> CGPoint
    func pathRideAnimation( cgPath: CGPath,
                            percent: CFloat,
                            timingFunction: CAMediaTimingFunction ,
                            duration: TimeInterval) -> CAAnimation?
    
    func animateLayerPathRideToPoint(_ path: UIBezierPath,
                                     layerToRide: CALayer,
                                     percent: CFloat,
                                     duration: TimeInterval) -> CAAnimation
    
}
