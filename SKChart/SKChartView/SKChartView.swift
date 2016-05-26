//
//  SKChartView.swift
//  Stock
//
//  Created on 25.05.16.
//  Copyright © 2016 SteelKiwi. All rights reserved.
//

import UIKit

private let minGridOffset: CGFloat = 3

@IBDesignable public class SKChartView: UIView {
    
    // MARK: - Public propertys
    
    /// Data for ChartView. Interface Builder does not support connecting to an outlet in a Swift file when the outlet’s type is a protocol. So temporary this object type is AnyObject
    @IBOutlet public var dataSourceObject: AnyObject!
    
    /// Color for line. Default is black
    @IBInspectable public var defaultLineColor: UIColor = UIColor.blackColor()
    
    /// Determines to show the labels on the left side of chart
    @IBInspectable public var showLeftLabels: Bool = false
    
    /// Color for grid. Default is lightGray
    @IBInspectable public var gridColor: UIColor = UIColor.lightGrayColor()
    
    /// Determines to show the vertical Grid
    @IBInspectable public var showVerticalGrid: Bool = true
    
    /// Distance between vertical lines of grid. Min value is 3
    @IBInspectable public var gridXOffset: CGFloat = 60.0 {
        didSet {
            if gridXOffset < minGridOffset { gridXOffset = minGridOffset }
        }
    }
    
    /// Determines to show the horizontal Grid
    @IBInspectable public var showHorizontalGrid: Bool = false
    
    /// Distance between horizontal lines of grid. Min value is 3
    @IBInspectable public var gridYOffset: CGFloat = 60.0 {
        didSet {
            if gridYOffset < minGridOffset { gridYOffset = minGridOffset }
        }
    }
    
    /// Determines to show the signs
    @IBInspectable public var showValues: Bool = true
    
    /// Determines to show dots on lines
    @IBInspectable public var showDots: Bool = true
    
    /// Determines to show the popup view with detail values
    @IBInspectable public var showPopupOnTouch: Bool = false
    
    /// Determines color for popup background. Default is clearColor
    @IBInspectable public var popupBackgound: UIColor = UIColor.clearColor()
    
    /**
     Reloads all of the data for the chart view.
     Call this method to reload all of the items in the chart view. This causes the chart view to discard any currently visible items and redisplay them.
     */
    public func reloadData() {
        
        valuesArray.removeAll()
        colorsArray.removeAll()
        
        guard dataSource != nil else {
            return
        }
        
        // No negative values for lines count
        let numberOfLines = max(dataSource!.chartViewNumberOfLines(self), 0)
        
        for lineIndex in 0 ..< numberOfLines {
            valuesArray.append(dataSource!.chartView(self, valuesForLine: lineIndex))
        }
        
        self.setNeedsDisplay()
    }
    
    // MARK: - Private variables
    
    // Wrapper for AnyObject
    private var dataSource: SKChartViewDataSource? { return dataSourceObject as? SKChartViewDataSource }
    private var valuesArray = [[CGFloat]]()
    private var colorsArray = [UIColor]()
    
    private var popupView: SKChartPopupView?
    
    private var leftLabelsWidth: CGFloat = 0 {
        didSet {
            leftLabelFrame = CGRectMake(0, 0, leftLabelsWidth, frame.height)
            chartFrame     = CGRectMake(leftLabelFrame.width, 0, frame.width - leftLabelFrame.width, frame.height)
        }
    }
    private var leftLabelFrame: CGRect = CGRectZero
    private var chartFrame: CGRect = CGRectZero
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Draw
    
    override public func drawRect(rect: CGRect) {
        
        self.reloadData()
        
        if showLeftLabels {
            self.drawLeftLabels()
        }
        
        self.drawGrid()
        
        #if TARGET_INTERFACE_BUILDER
            self.drawTestLine()
        #endif
        
        self.drawLines()
    }
    
    /**
     Calculate distance between X values
     
     - returns: Offset between X values
     */
    private func calculateXoffset() -> CGFloat {
        var XvalueCount = 0
        for array in valuesArray {
            if array.count > XvalueCount { XvalueCount = array.count }
        }
        
        return (frame.width - leftLabelsWidth) / CGFloat(XvalueCount - 1)
    }
    
    /**
     Calculate distance between Y values
     
     - returns: Tuple, which contains: offset - Offset between Y values, maxValue & minValue - maximum & minimum values
     */
    private func calculateYoffset() -> (offset: CGFloat, maxValue: CGFloat, minValue: CGFloat)  {
        var maxValue: CGFloat = valuesArray.first?.first ?? 0
        var minValue: CGFloat = valuesArray.first?.first ?? 0
        
        for array in valuesArray {
            for number in array {
                if number > maxValue { maxValue = number }
                if number < minValue { minValue = number }
            }
        }
        
        maxValue += abs(minValue)
        
        return (frame.height / maxValue, maxValue, minValue)
    }
    
    /**
     Calculate leftLabels frame and display values for horizontal grid
     */
    private func drawLeftLabels() {
        
        let maxValue = calculateYoffset().maxValue
        let decimalOffset: CGFloat = 20
        
        let maxValueString = NSString(format: (maxValue == floor(maxValue) ? "%.0f" : "%.2f"), maxValue)
        let font = UIFont.systemFontOfSize(12)
        
        let labelSize = maxValueString.sizeWithAttributes([NSFontAttributeName : font])
        
        leftLabelsWidth = labelSize.width + decimalOffset
        
        let labelsCount = frame.height / gridYOffset
        let valuePerLabel = maxValue / labelsCount
        
        
        for var labelIndex: CGFloat = 0; labelIndex < labelsCount; ++labelIndex {
            let value = valuePerLabel * labelIndex
            self.drawValue(value, forPoint: CGPointMake(0, frame.height - (labelSize.height / 2) - (labelIndex * gridYOffset)), color: self.gridColor)
        }
        
    }
    
    /**
     Display horizontal and vertical grid with defined color
     */
    private func drawGrid() {
        
        let gridLine = UIBezierPath()
        gridLine.lineWidth = 1
        
        if showVerticalGrid {
            for var x: CGFloat = leftLabelsWidth; x < frame.width; x += gridXOffset {
                gridLine.moveToPoint(CGPoint(x: x, y: 0))
                gridLine.addLineToPoint(CGPoint(x: x, y: frame.height))
            }
        }
        
        if showHorizontalGrid {
            for var y = frame.height; y > 0; y -= gridYOffset {
                gridLine.moveToPoint(CGPoint(x: leftLabelsWidth, y: y))
                gridLine.addLineToPoint(CGPoint(x: frame.width, y: y))
            }
        }
        
        self.gridColor.setStroke()
        gridLine.stroke()
    }
    
    /**
     Add test line for Interface builder testing
     */
    private func drawTestLine() {
        
        let lineValues: [CGFloat] = [14, 04, 22, 12, 27]
        let xOffset = (frame.width - leftLabelsWidth) / CGFloat(lineValues.count - 1)
        let yOffset = frame.height / 27
        
        let path = UIBezierPath()
        path.lineWidth = 1
        
        self.defaultLineColor.setStroke()
        
        for var i = 0; i < lineValues.count; ++i {
            
            let value = lineValues[i] * yOffset
            let point = CGPoint(x: leftLabelsWidth + CGFloat(i) * xOffset, y: frame.height - value)
            
            path.empty ? path.moveToPoint(point) : path.addLineToPoint(point)
            
            if showDots {
                self.drawDotInPoint(point, color: self.defaultLineColor)
            }
            
            if showValues {
                drawValue(lineValues[i], forPoint: point, color: self.defaultLineColor)
            }
        }
        
        path.stroke()
    }
    
    /**
     Display lines from delegate
     */
    private func drawLines() {
        
        let xOffset = calculateXoffset()
        let yData = calculateYoffset()
        let yOffset = yData.offset
        let maxValue = yData.maxValue
        let minValue = yData.minValue
        
        for var lineIndex = 0; lineIndex < valuesArray.count; lineIndex++ {
            
            let path = UIBezierPath()
            path.lineWidth = 1
            
            let lineColor = dataSource!.chartView(self, colorForLine: lineIndex) ?? self.defaultLineColor
            colorsArray.append(lineColor)
            lineColor.setStroke()
            
            let lineValues = valuesArray[lineIndex]
            
            for var i = 0; i < lineValues.count; ++i {
                let value = (maxValue - lineValues[i] - abs(minValue)) * yOffset
                let point = CGPoint(x: leftLabelsWidth + CGFloat(i) * xOffset, y: value)
                
                if path.empty {
                    path.moveToPoint(point)
                } else {
                    path.addLineToPoint(point)
                }
                
                if showDots {
                    self.drawDotInPoint(point, color: lineColor)
                }
                
                if showValues {
                    drawValue(lineValues[i], forPoint: point, color: lineColor)
                }
            }
            
            path.stroke()
        }
    }
    
    /**
     Display dots on lines if allowed
     
     - parameter point: Point, where dot will be displayed
     - parameter color: Color for dot
     */
    private func drawDotInPoint(point: CGPoint, color: UIColor) {
        color.setFill()
        UIBezierPath(ovalInRect: CGRectMake(point.x - 2, point.y - 2, 4, 4)).fill()
    }
    
    private func drawValue(value: CGFloat, var forPoint point: CGPoint, color: UIColor) {
        let string: NSString = NSString(format: (value == floor(value) ? "%.0f" : "%.2f"), value)
        let font = UIFont.systemFontOfSize(12)
        let attributes = [NSFontAttributeName : font,
            NSForegroundColorAttributeName : color]
        
        let stringSize = string.sizeWithAttributes(attributes)
        
        if point.x + stringSize.width >= frame.width - leftLabelsWidth {
            point.x = frame.width - leftLabelsWidth - stringSize.width
        }
        
        if point.y + stringSize.height >= frame.height {
            point.y = frame.height - stringSize.height
        }
        
        string.drawAtPoint(point, withAttributes: attributes)
    }
    
    // MARK: - Touches
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        popupView = SKChartPopupView()
        popupView?.backgroundColor = popupBackgound
        self.addSubview(popupView!)
        
        self.updatePopup(getPointFromTouch(touches.first!))
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.updatePopup(getPointFromTouch(touches.first!))
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        popupView?.removeFromSuperview()
    }
    
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        popupView?.removeFromSuperview()
    }
    
    /**
     Get touch coordinate limited by chart frame
     
     - parameter touch: Original touch
     
     - returns: Touch coordinate in chartFrame with limitations
     */
    private func getPointFromTouch(touch: UITouch) -> CGPoint {
        let touchPoint = touch.locationInView(self)
        
        let x = touchPoint.x < chartFrame.origin.x ? chartFrame.origin.x : (touchPoint.x > frame.width ? frame.width : touchPoint.x)
        let y = touchPoint.y < 0 ? 0 : (touchPoint.y > frame.height ? frame.height : touchPoint.y)
        
        return CGPointMake(x, y)
    }
    
    /**
     Get line values for selected Y point
     
     - parameter point: Touch point
     
     - returns: Array of lines values for selected Y coordinate
     */
    private func valuesForPoint(point: CGPoint) -> [CGFloat]{
        var values = [CGFloat]()
        
        let xOffset = calculateXoffset()
        
        let fromIndex = Int((point.x - leftLabelsWidth) / xOffset)
        
        for var lineValues in valuesArray
        {
            if fromIndex + 1 < lineValues.count {
                let fromValue = lineValues[fromIndex]
                let toValue = lineValues[fromIndex + 1]
                
                let valuePerPixel = (toValue - fromValue) / xOffset
                
                let fromPoint = CGFloat(fromIndex) * xOffset
                
                let value = fromValue + (point.x - fromPoint) * valuePerPixel
                values.append(value)
            } else {
                values.append(0)
            }
        }
        
        return values
    }
    
    /**
     Update char popup with new position and values
     
     - parameter touchPoint: Touch coordinate for new values observing
     */
    private func updatePopup(touchPoint: CGPoint) {
        popupView!.colors = colorsArray
        popupView?.values = valuesForPoint(touchPoint)
        
        let x = touchPoint.x + popupView!.size.width > frame.width ? frame.width - popupView!.size.width : touchPoint.x
        let y = touchPoint.y + popupView!.size.height > frame.height ? frame.height - popupView!.size.height : touchPoint.y
        
        popupView?.frame = CGRectMake(x, y, popupView!.size.width, popupView!.size.height)
    }
}
