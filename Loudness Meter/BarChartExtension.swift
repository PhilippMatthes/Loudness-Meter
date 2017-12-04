//
//  BarChartExtension.swift
//  Loudness Meter
//
//  Created by Philipp Matthes on 04.12.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import Charts

enum BarChartStyle {
    case normal
    case reflection
}

extension BarChartView {
    
    func setUpChart(withMeasurement measurement: Measurement,
                    andStyle style: BarChartStyle,
                    withDelegate delegate: ChartViewDelegate) {
        
        guard
            let soundLog = measurement.soundLog,
            let floatMax = soundLog.max()
        else {
            print("BCVE: Error initializing Bar Chart")
            return
        }
        
        if soundLog.count == 0 {return}
        
        let max = Double(floatMax)
        
        self.delegate = delegate
        self.chartDescription?.text = nil
        self.alpha = 0.3
        self.leftAxis.axisMinimum = 0
        self.rightAxis.enabled = false
        self.leftAxis.enabled = false
        self.xAxis.enabled = false
        self.drawBordersEnabled = false
        self.legend.enabled = false
        self.isUserInteractionEnabled = false
        
        switch style {
        case .normal:
            break
        case .reflection:
            self.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 1.0, 0.0, 0.0)
        }
    
        var barChartEntries = [BarChartDataEntry]()
        var barChartColors = [UIColor]()
        
        
        for i in 0..<soundLog.count {
            let sound = soundLog[i]
            let value = BarChartDataEntry(x: Double(i), y: Double(sound))
            barChartEntries.insert(value, at: 0)
            
            var fraction = CGFloat(0.0)
            if max != 0.0 {
                fraction = CGFloat(Double(sound)/max)
            }
            let color = Constants.transparentColor.interpolateRGBColorTo(end: Constants.whiteColor, fraction: fraction)
            barChartColors.insert(color!, at: 0)
        }
        
        
        let soundLine = BarChartDataSet(values: barChartEntries, label: nil)
        soundLine.colors = barChartColors
        
        let data = BarChartData()
        
        data.addDataSet(soundLine)
        
        data.setDrawValues(false)
        
        self.data = data
        self.notifyDataSetChanged()
    }
    
}
