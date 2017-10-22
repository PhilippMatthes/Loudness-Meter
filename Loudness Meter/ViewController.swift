//
//  ViewController.swift
//  Loudness Meter
//
//  Created by Philipp Matthes on 12.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var buttonImage: UIImageView!
    @IBOutlet weak var buttonBackground: UIView!
    @IBOutlet weak var informationImage: UIImageView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var loudnessLabel: UILabel!
    @IBOutlet weak var barBackground: UIView!
    var loudnessBar: LoudnessBar!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    weak var timer: Timer?
    weak var informationTimer: Timer?
    weak var recordingTimer: Timer?
    
    var maxLoudness = CGFloat(0)
    var currentLoudness = CGFloat(0)
    var currentBackgroundColors = [CGColor]()
    let gradientLayer = CAGradientLayer()
    
    var currentMeasurementIdentifier = 0
    var currentMeasurement: Measurement?
    
    var isRunning = false
    
    var soundLog = [Double]()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        currentMeasurementIdentifier = countSavedMeasurements()
        setUpBackground(with: view.frame, on: view)
        setUpLoudnessBar(with: view.frame, on: barBackground)
        setUpInterfaceDesign()
        
    }
    
    func countSavedMeasurements() -> Int {
        var measurements = [Measurement]()
        var count = 0
        if let decoded = UserDefaults.standard.object(forKey: "measurements") as? NSData {
            measurements = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as! [Measurement]
            count = measurements.count
        }
        
        currentMeasurement = measurements.last
        if currentMeasurement == nil {
            let currentDate = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
            currentMeasurement = Measurement(identifier: String(count), soundLog: [0.0], date: currentDate)
        }
        
        return count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpRecorder()
        startRecording()
        startUpdatingLevels()
        startUpdatingInformation(withInterval: 2.0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        finishRecording(success: true)
        stopUpdatingLevels()
        stopUpdatingInformation()
        recordingTimer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        stop()
    }
    
    func setUpInterfaceDesign() {
        buttonBackground.layer.cornerRadius = 35
        let buttonRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.buttonClicked(sender:)))
        buttonBackground.addGestureRecognizer(buttonRecognizer)
    }
    
    func setUpLoudnessBar(with frame: CGRect, on view: UIView) {
        loudnessBar = LoudnessBar(frame: frame)
        loudnessBar.drawBar(with: view.frame, on: view)
        loudnessBar.animateBar(duration: 1.0,
                               currentValue: 100,
                               maxValue: 100)
        self.view.addSubview(barBackground)
    }

    func setUpBackground(with frame: CGRect, on view: UIView) {
        gradientLayer.frame = frame
        currentBackgroundColors = [Constants.backgroundColor0.cgColor as CGColor,
                                   Constants.backgroundColor0.cgColor as CGColor]
        gradientLayer.colors = currentBackgroundColors
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func startRecording() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.audioRecorder!.record()
                        print("Starting audio recording")
                    } else {
                        print("Failed to start audio recording")
                    }
                }
            }
        } catch {
            print("Failed to start audio recording")
        }
    }
    
    
    func setUpRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            
        } catch {
            finishRecording(success: false)
        }
        
        print(audioRecorder.debugDescription)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            print("Successfully stopped Audio recorder")
        } else {
            print("Audio recorder could not be stopped")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @objc func updateLevels() {
        if audioRecorder != nil
        {
            audioRecorder!.updateMeters()
            let x = Double(audioRecorder!.peakPower(forChannel: 0))
            
            
            
            var decibel = CGFloat( 8.43e-4*pow(x,3) + 0.14*pow(x,2) + 7.54*x + 137.92 )
            if decibel < 0 {
                decibel = 0
            }
            if decibel >= maxLoudness {
                maxLoudness = decibel
            }
            loudnessLabel.text = String(Int(decibel))
            currentLoudness = decibel
            loudnessBar.animateBar(duration: 0.16, currentValue: decibel, maxValue: maxLoudness)
        }
    }
    
    func startUpdatingLevels() {
        updateInformation()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateLevels), userInfo: nil, repeats: true)
    }
    
    func stopUpdatingLevels() {
        timer?.invalidate()
    }
    
    func startUpdatingInformation(withInterval interval: TimeInterval) {
        informationTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateInformation), userInfo: nil, repeats: true)
    }
   
    @objc func updateInformation() {
        var selector = Int(currentLoudness/10)
        if selector > Constants.information.count - 1 {
            selector = Constants.information.count - 1
        }
        let toImage = Constants.information[selector].0
        let toText = Constants.information[selector].1
        UIView.transition(with: informationImage,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {self.informationImage.image = toImage},
                          completion: nil)
        UIView.transition(with: informationLabel,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {self.informationLabel.text = toText},
                          completion: nil)
        
        let bottomColor = Constants.backgroundColor0.interpolateRGBColorTo(end: Constants.backgroundColor1,
                                                                           fraction: currentLoudness/140)
        let topColor = Constants.backgroundColor0.interpolateRGBColorTo(end: Constants.backgroundColor1,
                                                                           fraction: currentLoudness/140)
        animateBackground(toColors: [bottomColor!.cgColor,
                                     topColor!.cgColor],
                          duration: 1.0)
        currentBackgroundColors = [bottomColor!.cgColor,
                                   topColor!.cgColor]
    }
    
    func stopUpdatingInformation() {
        informationTimer?.invalidate()
    }
    
    func animateBackground(toColors: [CGColor], duration: CFTimeInterval){
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        
        animation.fromValue = currentBackgroundColors
        animation.toValue = toColors
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        
        gradientLayer.add(animation, forKey: "animateGradient")
    }
    
    @IBAction func userDidSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "showDetailView", sender: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func buttonClicked(sender:UITapGestureRecognizer) {
        if isRunning {
            stop()
            animateButtonReleaseOff(background: buttonBackground)
            let toImage = UIImage(named: "RecordButton")
            UIView.transition(with: buttonImage,
                              duration: 0.3,
                              options: .transitionFlipFromTop,
                              animations: {self.buttonImage.image = toImage},
                              completion: nil)
        }
        else {
            start()
            animateButtonPressOn(background: buttonBackground)
            let toImage = UIImage(named: "StopButton")
            UIView.transition(with: buttonImage,
                              duration: 0.3,
                              options: .transitionFlipFromBottom,
                              animations: {self.buttonImage.image = toImage},
                              completion: nil)
        }
    }
    
    func start() {
        isRunning = true
        soundLog = [Double]()
        loudnessBar.line.strokeColor = Constants.backgroundColor1.cgColor
        recordingTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                         target: self,
                                         selector: #selector(appendAmplitudeToSoundLog(timer:)),
                                         userInfo: nil,
                                         repeats: true)
    }
    
    func stop() {
        isRunning = false
        loudnessBar.line.strokeColor = UIColor.white.cgColor
        recordingTimer?.invalidate()
        updateCurrentMeasurement()
        performSegue(withIdentifier: "showDetailView", sender: self)
    }
    
    func animateButtonPressOn(background: UIView) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = 0
        borderWidth.toValue = 4.0
        borderWidth.duration = 0.1
        background.layer.borderWidth = 0.0
        background.layer.borderColor = Constants.backgroundColor1.cgColor
        background.layer.add(borderWidth, forKey: "Width")
        background.layer.borderWidth = 4.0
    }
    
    func animateButtonReleaseOff(background: UIView) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = 4.0
        borderWidth.toValue = 0
        borderWidth.duration = 0.1
        background.layer.borderWidth = 4.0
        background.layer.borderColor = Constants.backgroundColor1.cgColor
        background.layer.add(borderWidth, forKey: "Width")
        background.layer.borderWidth = 0.0
    }
    
    func updateCurrentMeasurement() {
        currentMeasurementIdentifier += 1
        let currentDate = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
        currentMeasurement = Measurement(identifier: String(currentMeasurementIdentifier),
                                         soundLog: soundLog,
                                         date: currentDate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            let vc = segue.destination as! DetailViewController
            vc.currentMeasurement = currentMeasurement
        }
    }
    
    
    @objc func appendAmplitudeToSoundLog(timer: Timer) {
        soundLog.append(Double(currentLoudness))
    }
    
}

