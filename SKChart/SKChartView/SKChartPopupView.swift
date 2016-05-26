//
//  SKChartPopupView.swift
//  Stock
//
//  Created on 25.05.16.
//  Copyright © 2016 SteelKiwi. All rights reserved.
//

import UIKit

public class SKChartPopupView: UIView {
    
    /// Colors for labels on popup
    public var colors: [UIColor]?
    
    /// values for labels on popup
    public var values: [CGFloat]? {
        didSet {
            self.updateView()
        }
    }
    
    /// Size of popup
    public var size: CGSize = CGSizeZero
    
    private func updateView() {
        
        for subview in subviews { subview.removeFromSuperview() }
        
        var y: CGFloat = 0
        var newWidth: CGFloat = 50
        
        for var valueIndex = 0; valueIndex < values!.count; ++valueIndex {
            let value = values![valueIndex]
            let label = UILabel()
            label.font = UIFont.systemFontOfSize(12)
            label.textColor = colors![valueIndex]
            label.text = NSString(format: "%.2f", value) as String
            label.sizeToFit()
            
            if label.frame.width > newWidth { newWidth = label.frame.width }
            label.frame = CGRectMake(0, y, label.frame.width, label.frame.height)
            self.addSubview(label)
            
            y += label.frame.height
        }
        
        size = CGSizeMake(newWidth, y)
    }
    
}
