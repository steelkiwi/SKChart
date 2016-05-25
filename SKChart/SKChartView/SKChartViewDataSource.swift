//
//  SKChartViewDataSource.swift
//  Stock
//
//  Created on 25.05.16.
//  Copyright © 2016 SteelKiwi. All rights reserved.
//

import UIKit

@objc
public protocol SKChartViewDataSource {
    /**
     Asks the data source to return the number of lines in the chartView.
     
     - parameter chartView: An object representing the chartView requesting this information.
     
     - returns: The number of lines in chartView.
     */
    func chartViewNumberOfLines(chartView: SKChartView) -> Int
    
    /**
     Values for line.
     
     - parameter chartView:  An object representing the chartView requesting this information.
     - parameter lineIndex:  An index number identifying a line in chartView
     
     - returns: The array of values for specific line
     */
    func chartView(chartView: SKChartView, valuesForLine lineIndex: Int) -> [CGFloat]
    
    /**
     Color for line. Default is black.
     
     - parameter chartView: An object representing the chartView requesting this information.
     - parameter lineIndex: An index number identifying a line in chartView
     
     - returns: The color for specific line in chartView
     */
    func chartView(chartView: SKChartView, colorForLine lineIndex: Int) -> UIColor?
    
    /**
     Name for line label. Required if showVerticalSigns is true
     
     - parameter chartView: An object representing the chartView requesting this information.
     - parameter lineIndex: An index number identifying a line in chartView
     
     - returns: The line name for displaying on labels view
     */
    optional func chartView(chartView: SKChartView, nameForLine lineIndex: Int) -> String
}
