//
//  MeasurementCell.swift
//  Loudness Meter
//
//  Created by Philipp Matthes on 21.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Charts

class MeasurementCell: UITableViewCell, ChartViewDelegate {
    
    @IBOutlet weak var reflectionChart: BarChartView!
    @IBOutlet weak var soundChart: BarChartView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var loudnessLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowOpacity = 0.18
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        self.layer.backgroundColor = Constants.backgroundColor0.cgColor
        self.isHidden = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpChart(measurement: Measurement) {
        let soundLog = measurement.soundLog!
        if soundLog.count == 0 {
            return
        }
        let max = Double(soundLog.max()!)
        
        soundChart.delegate = self
        soundChart.chartDescription?.text = nil
        soundChart.alpha = 0.3
        soundChart.leftAxis.axisMinimum = 0
        soundChart.rightAxis.enabled = false
        soundChart.leftAxis.enabled = false
        soundChart.xAxis.enabled = false
        soundChart.drawBordersEnabled = false
        soundChart.legend.enabled = false
        soundChart.isUserInteractionEnabled = false
        
        reflectionChart.delegate = self
        reflectionChart.alpha = 0.3
        reflectionChart.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 1.0, 0.0, 0.0)
        reflectionChart.chartDescription?.text = nil
        reflectionChart.leftAxis.axisMinimum = 0
        reflectionChart.rightAxis.enabled = false
        reflectionChart.leftAxis.enabled = false
        reflectionChart.xAxis.enabled = false
        reflectionChart.drawBordersEnabled = false
        reflectionChart.legend.enabled = false
        reflectionChart.isUserInteractionEnabled = false
        
        
        var barChartEntries = [BarChartDataEntry]()
        var barChartColors = [UIColor]()
        
        //        let maxSpeed = speedLog.max(by: {$0.1 < $1.1 })!.1
        
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
        
        
        let soundLine = BarChartDataSet(values: barChartEntries, label: "Test")
        soundLine.colors = barChartColors
        
        let data = BarChartData()
        
        data.addDataSet(soundLine)
        
        data.setDrawValues(false)
        
        soundChart.data = data
        reflectionChart.data = data
        soundChart.notifyDataSetChanged()
        reflectionChart.notifyDataSetChanged()
    }
    
    
}
