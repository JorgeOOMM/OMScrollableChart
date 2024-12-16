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

protocol PointsGeneratorModelProtocol {
    var pointScaler: PointScalerGeneratorProtocol! {get set}
    func rawPoints(_ data: [Float], size: CGSize) -> [CGPoint]
    func averagedPoints( data: [Float], size: CGSize, elementsToAverage: Int) -> [CGPoint]
    func simplifiedPoints( points: [CGPoint], tolerance: CGFloat) -> [CGPoint]
}

class PointsGeneratorModel: PointsGeneratorModelProtocol {
    var pointScaler: PointScalerGeneratorProtocol!
    init(pointScaler: PointScalerGeneratorProtocol!) {
        self.pointScaler = pointScaler
    }
    func rawPoints(_ data: [Float], size: CGSize) -> [CGPoint] {
        pointScaler.updateRangeLimits(data)
        return pointScaler.makePoints(data: data, size: size)
    }
    func averagedPoints( data: [Float], size: CGSize, elementsToAverage: Int) -> [CGPoint] {
        if elementsToAverage > 0 {
            var result: Float = 0
            let chunked = data.chunked(into: elementsToAverage)
            let averagedData: [Float] = chunked.map {
                vDSP_meanv($0, 1, &result, vDSP_Length($0.count));
                return result
            }
            pointScaler.updateRangeLimits(averagedData)
            return pointScaler.makePoints(data: averagedData, size: size)
        }
        return []
    }
    func simplifiedPoints( points: [CGPoint], tolerance: CGFloat) -> [CGPoint] {
        guard tolerance > 0, points.isEmpty == false else {
            return []
        }
        return  PolylineSimplify.simplify(points, tolerance: Float(tolerance))
    }
}
