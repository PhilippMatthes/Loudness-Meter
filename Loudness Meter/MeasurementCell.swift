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
    
    
}
