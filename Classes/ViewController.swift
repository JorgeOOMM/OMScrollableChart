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

import UIKit

let chartPoints: [Float] =   [1510, 100,
                              3000, 100,
                              1200, 13000,
                              15000, -1500,
                              800, 1000,
                              1510, 100,
                              3000, 100,
                              1200, 13000,
                              15000, 1600,
                              800, 1000]


class ViewController: UIViewController, DataSourceProtocol {
    func dataPoints(chart: OMScrollableChart, renderIndex: Int, section: Int) -> [Float] {
        return chartPoints
    }
    func footerSectionsText(chart: OMScrollableChart) -> [String]? {
        return nil
    }
    func dataPointTootipText(chart: OMScrollableChart, renderIndex: Int, dataIndex: Int, section: Int) -> String? {
        return nil
    }
    func dataOfRender(chart: OMScrollableChart, renderIndex: Int) -> RenderType {
        return renderType
    }
    func dataSectionForIndex(chart: OMScrollableChart, dataIndex: Int, section: Int) -> String? {
        return nil
    }
    func numberOfPages(chart: OMScrollableChart) -> CGFloat {
        return 2
    }
    func numberOfSectionsPerPage(chart: OMScrollableChart) -> Int {
        return 12
    }
    
    @IBOutlet var toleranceSlider: UISlider!
    @IBOutlet var sliderLimit: UISlider!
    @IBOutlet var chart: OMScrollableChart!
    @IBOutlet var segmentInterpolation: UISegmentedControl!
    @IBOutlet var segmentTypeOfData: UISegmentedControl!
    @IBOutlet var sliderAverage: UISlider!
    
    deinit {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        chart.bounces = false
        chart.dataSource = self
        chart.backgroundColor = .clear
        chart.isPagingEnabled = true
        
        segmentInterpolation.removeAllSegments()
        segmentInterpolation.insertSegment(withTitle: "none", at: 0, animated: false)
        segmentInterpolation.insertSegment(withTitle: "smoothed", at: 1, animated: false)
        segmentInterpolation.insertSegment(withTitle: "cubicCurve", at: 2, animated: false)
        segmentInterpolation.insertSegment(withTitle: "hermite", at: 3, animated: false)
        segmentInterpolation.insertSegment(withTitle: "catmullRom", at: 4, animated: false)
        segmentInterpolation.selectedSegmentIndex = 4 // catmullRom
        chart.polylineInterpolation = .catmullRom(0.5)
        
        segmentTypeOfData.removeAllSegments()
        segmentTypeOfData.insertSegment(withTitle: "discrete", at: 0, animated: false)
        segmentTypeOfData.insertSegment(withTitle: "averaged", at: 1, animated: false)
        segmentTypeOfData.insertSegment(withTitle: "simplify", at: 2, animated: false)
        segmentTypeOfData.insertSegment(withTitle: "regression", at: 3, animated: false)
        segmentTypeOfData.selectedSegmentIndex = 0 // discrete
        
        toleranceSlider.maximumValue  = 20
        toleranceSlider.minimumValue  = 1
        toleranceSlider.value         = Float(self.chart.simplifiedTolerance)
        sliderAverage.maximumValue    = Float(chartPoints.count)
        sliderAverage.minimumValue    = 0
        sliderAverage.value           = Float(self.chart.numberOfElementsToAverage)
        
        _ = chart.updateDataSourceData()
        
        if let scaledPointsGenerator = chart.scaledPointsGenerator.first {
            sliderLimit.maximumValue  = scaledPointsGenerator.maximumValue
            sliderLimit.minimumValue  = scaledPointsGenerator.minimumValue
        }
        
    }
    @IBAction  func limitsSliderChange( _ sender: UISlider)  {
        if sender == sliderLimit {
            let generator = chart.scaledPointsGenerator.first
            generator?.minimum =  Float(CGFloat(sliderLimit.value))
            _ = chart.updateDataSourceData()
        }
    }
    @IBAction  func simplifySliderChange( _ sender: UISlider)  {
        if sender == sliderAverage {
            self.chart.numberOfElementsToAverage = Int(sliderAverage.value)
        } else {
            self.chart.simplifiedTolerance = CGFloat(toleranceSlider.value)
        }
    }
    @IBAction  func interpolationSegmentChange( _ sender: Any)  {
        switch segmentInterpolation.selectedSegmentIndex  {
        case 0:
            chart.polylineInterpolation = .none
        case 1:
            chart.polylineInterpolation = .smoothed
        case 2:
            chart.polylineInterpolation = .cubicCurve
        case 3:
            chart.polylineInterpolation = .hermite(0.5)
        case 4:
            chart.polylineInterpolation = .catmullRom(0.5)
        default:
            assert(false)
        }
    }
    var renderType: RenderType = .discrete
    @IBAction  func typeOfDataSegmentChange( _ sender: Any)  {
        switch segmentTypeOfData.selectedSegmentIndex  {
        case 0: renderType = .discrete
        case 1: renderType = .averaged(1)
        case 2: renderType = .simplified(0)
        case 3: renderType = .linregress(1)
        default:
            assert(false)
        }
        chart.updateLayoutForceReload()
    }
}
