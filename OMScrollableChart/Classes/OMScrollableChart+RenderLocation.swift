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
//  OMScrollableChart+RenderLocation.swift
//
//  Created by Jorge Ouahbi on 22/08/2020.
//  Copyright © 2020 dsp. All rights reserved.
//

import UIKit
// MARK: - RenderLocation protocol
extension OMScrollableChart: RenderLocationProtocol {
    
    /// indexForPoint
    /// - Parameters:
    ///   - point: CGPoint
    ///   - renderIndex: Int
    /// - Returns: Int?
    func indexForPoint(_ point: CGPoint, renderIndex: Int) -> Int? {
        let newPoint = CGPoint(x: point.x, y: point.y)
        switch self.renderType[renderIndex] {
        case .discrete:
            return discreteData[renderIndex]?.points.map{ $0.distance(newPoint)}.indexOfMin
        case .averaged(_):
            return averagedData[renderIndex]?.points.map{ $0.distance(newPoint)}.indexOfMin
        case .simplified(_):
            return approximationData[renderIndex]?.points.map{ $0.distance(newPoint)}.indexOfMin
        case .linregress(_):
            return linregressData[renderIndex]?.points.map{ $0.distance(newPoint)}.indexOfMin
        }
    }
    /// dataStringFromPoint
    /// - Parameters:
    ///   - point: CGPoint
    ///   - renderIndex: Int
    /// - Returns: String?
    func dataStringFromPoint(_ point: CGPoint, renderIndex: Int) -> String? {
        switch self.renderType[renderIndex] {
        case .averaged(_):
            if let render = averagedData[renderIndex],
                let firstIndex = indexForPoint(point, renderIndex: renderIndex) {
                let item: Double = Double(render.data[firstIndex])
                if let currentStep = numberFormatter.string(from: NSNumber(value: item)) {
                    return  currentStep
                }
            }
        case .discrete:
            if let render = discreteData[renderIndex],
                let firstIndex = render.points.firstIndex(of: point) {
                let item: Double = Double(render.data[firstIndex])
                if let currentStep = numberFormatter.string(from: NSNumber(value: item)) {
                    return currentStep
                }
            }
        case .simplified(_):
            if let render = approximationData[renderIndex],
                let firstIndex = render.points.firstIndex(of: point) {
                let item: Double = Double(render.data[firstIndex])
                if let currentStep = numberFormatter.string(from: NSNumber(value: item)) {
                    return currentStep
                }
            }
        case .linregress(_):
            if let render = linregressData[renderIndex],
                let firstIndex = render.points.firstIndex(of: point) {
                let item: Double = Double(render.data[firstIndex])
                if let currentStep = numberFormatter.string(from: NSNumber(value: item)) {
                    return currentStep
                }
            }
        }
        return nil
    }
    func dataFromPoint(_ point: CGPoint, renderIndex: Int) -> Float? {
//        if self.renderType[renderIndex].isAveraged {
//            if let render = discreteData[renderIndex],
//                let firstIndex = indexForPoint(point, renderIndex: renderIndex) {
//                return Float(render.data[firstIndex])
//            }
//        } else {
//            if let render = discreteData[renderIndex],
//                let firstIndex = render.points.firstIndex(of: point) {
//                return Float(render.data[firstIndex])
//            }
//        }
//        return nil
        switch self.renderType[renderIndex] {
        case .discrete:
            if let render = discreteData[renderIndex] {
                if let firstIndex = render.points.firstIndex(of: point) {
                    return render.data[firstIndex]
                }
            }
        case .averaged(_):
            if let render = self.averagedData[renderIndex] {
                if let firstIndex = indexForPoint(point, renderIndex: renderIndex) {
                    return render.data[firstIndex]
                }
            }
        case .simplified(_):
            if let render = self.approximationData[renderIndex] {
                if let firstIndex = render.points.firstIndex(of: point) {
                    return render.data[firstIndex]
                }
            }
        case .linregress(_):
            if let render = self.linregressData[renderIndex] {
                if let firstIndex = render.points.firstIndex(of: point) {
                    return render.data[firstIndex]
                }
            }
        }
        return nil
       // return dataIndexFromLayers(point, renderIndex: renderIndex)
    }
    func dataIndexFromPoint(_ point: CGPoint, renderIndex: Int) -> Int? {
        switch self.renderType[renderIndex] {
        case .discrete:
            if let render = discreteData[renderIndex] {
                if let firstIndex = render.points.firstIndex(of: point) {
                    return firstIndex
                }
            }
        case .averaged(_):
            if let firstIndex = indexForPoint(point, renderIndex: renderIndex) {
                return firstIndex
            }
            
        case .simplified(_):
            if let render = self.approximationData[renderIndex] {
                if let firstIndex = render.points.firstIndex(of: point) {
                    return firstIndex
                }
            }
        case .linregress(_):
            if let render = self.linregressData[renderIndex] {
                if let firstIndex = render.points.firstIndex(of: point) {
                    return firstIndex
                }
            }
        }
        return nil //dataIndexFromLayers(point, renderIndex: renderIndex)
    }
    func dataIndexFromLayers(_ point: CGPoint, renderIndex: Int) -> Int? {
        if self.renderType[renderIndex].isAveraged {
            if let firstIndex = indexForPoint(point, renderIndex: renderIndex) {
                return firstIndex
            }
        } else {
            if let layersPathContains = renderLayers[renderIndex].filter({
                return $0.path!.contains(point)
            }).first {
                return renderLayers[renderIndex].firstIndex(of: layersPathContains)
            }
        }
        return nil
    }
}
