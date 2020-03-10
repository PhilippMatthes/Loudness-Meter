//
//  MeasurementOrchestrator.swift
//  volume
//
//  Created by It's free real estate on 10.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import AVFoundation
import Combine


class MeasurementOrchestrator: NSObject, ObservableObject, AVAudioRecorderDelegate {
    enum Error {
        case initAudioRecorderFailed
        case setCategoryFailed
        case setActiveFailed
        case permissionDenied
        case finishRecordingFailed
    }
    
    public let objectWillChange = PassthroughSubject<Void, Never>()
    
    private var recordingSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    private var updateTimer: Timer?
    private var recordingStarted: Date?
    private var recordingEnded: Date?
    private var magnitudes: [Double] = []
    
    @Published public var currentMagnitude: Magnitude? = nil {
        willSet{objectWillChange.send()}
    }
    
    @Published public var measurement: Measurement? = nil {
        willSet{objectWillChange.send()}
    }
    
    @Published public var isRecording: Bool = false {
        willSet{objectWillChange.send()}
    }
    
    @Published public var didThrowError: Bool = false {
        willSet{objectWillChange.send()}
    }
    
    @Published public var error: MeasurementOrchestrator.Error? = nil {
        willSet{objectWillChange.send()}
    }
    
    private func prepareRecorder() {
        guard audioRecorder == nil else {return}
        
        guard let url = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("recording.m4a")
        else {
            return
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
        } catch {
            self.error = .initAudioRecorderFailed
            self.didThrowError = true
        }
    }
    
    public func startRecording(completion: (() -> ())? = nil) {
        prepareRecorder()
        recordingSession = .sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord)
        } catch {
            self.error = .setCategoryFailed
            didThrowError = true
        }
        
        do {
            try recordingSession?.setActive(true)
        } catch {
            self.error = .setActiveFailed
            self.didThrowError = true
        }
        
        recordingSession?.requestRecordPermission() {
            [unowned self] allowed in
            DispatchQueue.main.async {
                guard let audioRecorder = self.audioRecorder else {return}
                if allowed {
                    self.isRecording = true
                    self.recordingStarted = Date()
                    audioRecorder.record()
                    self.updateTimer = .scheduledTimer(
                        withTimeInterval: 0.1,
                        repeats: true,
                        block: self.updateLevels
                    )
                    completion?()
                } else {
                    self.error = .permissionDenied
                    self.didThrowError = true
                }
            }
        }
    }
    
    public func endRecording() {
        updateTimer?.invalidate()
        audioRecorder?.stop()
        audioRecorder = nil
        
        self.isRecording = false
        
        guard
            let recordingStarted = recordingStarted,
            magnitudes.count > 5
        else {return}
        
        self.measurement = Measurement(
            startDate: recordingStarted,
            endDate: Date(),
            magnitudes: self.magnitudes
        )
    }
        
    @objc func updateLevels(calledBy timer: Timer) {
        guard let audioRecorder = audioRecorder else {return}
        
        audioRecorder.updateMeters()
        currentMagnitude = Magnitude(audioRecorder.peakPower(forChannel: 0))
        magnitudes.insert(currentMagnitude!, at: 0)
    }
    
}
