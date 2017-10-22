//
//  DetailViewController.swift
//  Loudness Meter
//
//  Created by Philipp Matthes on 21.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import Foundation
import Charts

class DetailViewController: UIViewController, ChartViewDelegate {
    
    var currentBackgroundColors = [CGColor]()
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var loudnessLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var soundChart: BarChartView!
    @IBOutlet weak var reflectionChart: BarChartView!
    
    var currentMeasurement: Measurement?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpChart()
        setUpBackground(with: view.frame, on: view)
        setUpInterfaceDesign()
        setUpLabels()
    }
    

    @IBAction func userDidSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "showTable", sender: self)
    }
    

    @IBAction func userDidSwipeRight(_ sender: UISwipeGestureRecognizer) {
        performSegueToReturnBack()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setUpBackground(with frame: CGRect, on view: UIView) {
        gradientLayer.frame = frame
        currentBackgroundColors = [Constants.backgroundColor0.cgColor as CGColor,
                                   Constants.backgroundColor0.cgColor as CGColor]
        gradientLayer.colors = currentBackgroundColors
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setUpLabels() {
        let soundLog = currentMeasurement!.soundLog!
        let average = Double(soundLog.reduce(0, +)) / Double(soundLog.count)
        loudnessLabel.text = String(Int(average))
    }
    
    func setUpChart() {
        let soundLog = currentMeasurement!.soundLog!
        if soundLog.count == 0 {
            return
        }
        let max = Double(soundLog.max()!)
        
        soundChart.delegate = self
        soundChart.chartDescription?.text = nil
        soundChart.leftAxis.axisMinimum = 0
        soundChart.rightAxis.enabled = false
        soundChart.xAxis.enabled = false
        soundChart.drawBordersEnabled = false
        soundChart.legend.enabled = false
        soundChart.leftAxis.drawGridLinesEnabled = true
        soundChart.leftAxis.gridColor = UIColor.white
        soundChart.leftAxis.labelTextColor = UIColor.white
        soundChart.leftAxis.axisLineColor = UIColor.white
        soundChart.isUserInteractionEnabled = false
        
        reflectionChart.delegate = self
        reflectionChart.alpha = 0.2
        reflectionChart.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 1.0, 0.0, 0.0)
        reflectionChart.chartDescription?.text = nil
        reflectionChart.leftAxis.axisMinimum = 0
        reflectionChart.rightAxis.enabled = false
        reflectionChart.leftAxis.drawGridLinesEnabled = true
        reflectionChart.leftAxis.gridColor = UIColor.white
        reflectionChart.leftAxis.labelTextColor = UIColor.white
        reflectionChart.leftAxis.axisLineColor = UIColor.white
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
        
        soundChart.animate(xAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCubic)
        reflectionChart.animate(xAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCubic)
        
        soundChart.data = data
        reflectionChart.data = data
        soundChart.notifyDataSetChanged()
        reflectionChart.notifyDataSetChanged()
    }
    
    func setUpInterfaceDesign() {
        let navigationItem = UINavigationItem(title: NSLocalizedString("messung", comment: " "))
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.doneButtonPressed (_:)))
        let editItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector (self.saveButtonPressed (_:)))
        editItem.tintColor = Constants.backgroundColor0
        doneItem.tintColor = Constants.backgroundColor0
        navigationItem.rightBarButtonItem = doneItem
        navigationItem.leftBarButtonItem = editItem
        navigationBar.setItems([navigationItem], animated: false)
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Constants.backgroundColor0]
        
    }
    
    @objc func doneButtonPressed(_ sender:UITapGestureRecognizer) {
        performSegueToReturnBack()
    }
    
    @objc func saveButtonPressed(_ sender:UITapGestureRecognizer) {
        saveCurrentTime()
        performSegue(withIdentifier: "showTable", sender: self)
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func saveCurrentTime() {
        if let _ = currentMeasurement {
            var measurements = [Measurement]()
            if let decoded = UserDefaults.standard.object(forKey: "measurements") as? NSData {
                let array = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as! [Measurement]
                measurements = array
            }
            
            measurements += [currentMeasurement!]
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: measurements)
            UserDefaults.standard.set(encodedData, forKey: "measurements")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTable" {
            let vc = segue.destination as! TableViewController
            vc.previousViewController = self
        }
    }
}
