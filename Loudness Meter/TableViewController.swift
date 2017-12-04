//
//  TableViewController.swift
//  Loudness Meter
//
//  Created by Philipp Matthes on 21.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import Charts
import Foundation

class TableViewController: UITableViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var previousViewController: DetailViewController?
    var measurements = [Measurement]()
    var selector = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterfaceDesign()
        tableView.separatorStyle = .singleLineEtched
        tableView.separatorColor = UIColor.white
        
        if let decoded = UserDefaults.standard.object(forKey: "measurements") as? NSData {
            let array = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as! [Measurement]
            measurements = array.reversed()
        }
    }
    
    @IBAction func userDidSwipeRight(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "showDetailView", sender: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setUpInterfaceDesign() {
        let navigationItem = UINavigationItem(title: NSLocalizedString("gespeicherteMessungen", comment: " "))
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.doneButtonPressed (_:)))
        let editItem = editButtonItem
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
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measurements.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 200.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "MeasurementCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MeasurementCell else {
            fatalError("The dequeued cell is not an instance of MeasurementCell.")
        }
        
        let measurement = measurements[indexPath.row]
        
        cell.soundChart.setUpChart(withMeasurement: measurement,
                                   andStyle: .normal,
                                   withDelegate: cell)
        cell.reflectionChart.setUpChart(withMeasurement: measurement,
                                        andStyle: .reflection,
                                        withDelegate: cell)
        cell.dateLabel.text = measurement.date
        cell.loudnessLabel.text = String(Int(Double(measurement.soundLog!.reduce(0, +)) / Double(measurement.soundLog!.count)))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            measurements.remove(at: indexPath.row)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: measurements)
            UserDefaults.standard.set(encodedData, forKey: "measurements")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        setUpInterfaceDesign()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selector = indexPath
        previousViewController?.currentMeasurement = measurements[selector.row]
        performSegueToReturnBack()
    }
    
    
}
