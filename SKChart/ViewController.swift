//
//  ViewController.swift
//  SKChart
//
//  Created on 25.05.16.
//  Copyright © 2016 SteelKiwi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SKChartViewDataSource {
    
    private var values: [[CGFloat]] = [
        [15, 22, 07, 17, 31],
        [11, 14, 02, -5, 27]
    ]
    
    // MARK: - SKChartViewDataSource
    
    func chartViewNumberOfLines(chartView: SKChartView) -> Int {
        
        // Return number of lines
        return values.count
    }
    
    func chartView(chartView: SKChartView, valuesForLine lineIndex: Int) -> [CGFloat] {
        
        // Return array of CGFloat values for line
        return values[lineIndex]
    }
    
    func chartView(chartView: SKChartView, colorForLine lineIndex: Int) -> UIColor? {
        
        return lineIndex % 2 == 0 ? UIColor.redColor() : UIColor.blueColor()
    }
    
}