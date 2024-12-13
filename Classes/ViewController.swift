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
                              800, 1000,
                              1510, 100,
                              3000, 100,
                              1200, 13000,
                              15000, -1500,
                              800, 1000,
                              1510, 100,
                              3000, 100,
                              1200, 13000,
                              15000, 1600,
                              800, 1000]

class ViewController: UIViewController {
    @IBOutlet var chart: OMScrollableChart!
    @IBOutlet var segmentTypeOfData: UISegmentedControl!
    var renderType: RenderType = .discrete
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chart.bounces = false
        self.chart.dataSource = self
        self.chart.backgroundColor = .clear
        self.chart.isPagingEnabled = true
        segmentTypeOfData.removeAllSegments()
        segmentTypeOfData.insertSegment(withTitle: "discrete", at: 0, animated: false)
        segmentTypeOfData.insertSegment(withTitle: "regression", at: 1, animated: false)
        segmentTypeOfData.selectedSegmentIndex = 0 // discrete
        let _ = self.chart.updateBasicSourceData()
    }
    @IBAction  func typeOfDataSegmentChange( _ sender: Any)  {
        switch segmentTypeOfData.selectedSegmentIndex  {
        case 0: renderType = .discrete
        case 1: renderType = .linregress(1)
        default:
            assert(false)
        }
        self.chart.updateLayout()
    }
}

extension ViewController: DataSourceProtocol {
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
    func numberOfSectionsPerPage(chart: OMScrollableChart) -> Int {
        return 12
    }
}
