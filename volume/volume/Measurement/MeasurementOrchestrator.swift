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
    
    struct Data {
        var bands: [Magnitude]
        var currentMagnitude: Magnitude
        var digestedMagnitude: Magnitude
    }
    
    @Published public var data: MeasurementOrchestrator.Data
    public let objectWillChange = PassthroughSubject<MeasurementOrchestrator.Data, Never>()
    
    private var audioInput: TempiAudioInput?
    private let sampleRate: Float = 44100
    private let refreshRate: Double = 1
    private let numberOfBands = 24
    
    private var startDate: Date?
    private var magnitudes = [Magnitude]()
    private var magnitudesToDigest = [Magnitude]()
    private var digestInterval: TimeInterval
    private var digestTimer: Timer?
    
    
    init(bands: [Double] = [], currentMagnitude: Double = 0, digestedMagnitude: Double = 0, digestInterval: TimeInterval = 2) {
        data = .init(
            bands: bands,
            currentMagnitude: currentMagnitude,
            digestedMagnitude: digestedMagnitude
        )
        self.digestInterval = digestInterval
        super.init()
    }
    
    public func startReceivingSound(completion: @escaping (TempiAudioInput.Failure?) -> ()) {
        magnitudes = []
        startDate = Date()
        
        digestTimer = Timer.scheduledTimer(withTimeInterval: digestInterval, repeats: true) { _ in
            self.digestMagnitude()
        }
        
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.audioInputCallback(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }

        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: sampleRate, numberOfChannels: 1, refreshRate: refreshRate)
        audioInput?.startRecording(completion: completion)
    }
    
    @objc func digestMagnitude() {
        if !magnitudesToDigest.isEmpty {
            data.digestedMagnitude = magnitudesToDigest.reduce(0, +) / Double(magnitudesToDigest.count)
            magnitudesToDigest.removeAll()
        } else {
            data.digestedMagnitude = data.currentMagnitude
        }
        DispatchQueue.main.async {
            self.objectWillChange.send(self.data)
        }
    }
    
    private func audioInputCallback(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        // NB: The default buffer size on iOS is 512. This will not give a terribly high resolution.
        // In practice you'll want to bucket up the buffers into a larger array of at least size 2048.
        let fft = TempiFFT(withSize: numberOfFrames, sampleRate: sampleRate)
        fft.windowType = TempiFFTWindowType.hanning
        fft.fftForward(samples)
        fft.calculateLinearBands(
            minFrequency: 20,
            maxFrequency: fft.nyquistFrequency,
            numberOfBands: numberOfBands
        )

        let minDB: Double = -86
        
        data.bands = (0..<fft.numberOfBands).map { bandIndex in
            let magnitude = fft.magnitudeAtBand(bandIndex)
            // Incoming magnitudes are linear, making it impossible to see very low or very high values. Decibels to the rescue!
            let magnitudeDB = Double(TempiFFT.toDB(magnitude))
            // Normalize the incoming magnitude so that -Inf = 0
            return max(0, magnitudeDB + abs(minDB))
        }
        
        data.currentMagnitude = data.bands.reduce(0, +) / Double(data.bands.count)
        magnitudes.append(data.currentMagnitude)
        magnitudesToDigest.append(data.currentMagnitude)
        
        DispatchQueue.main.async {
            self.objectWillChange.send(self.data)
        }
    }
    
    struct EndReceivingSoundResponse {
        let failure: TempiAudioInput.Failure?
        let measurement: Measurement?
    }
    
    public func endReceivingSound(completion: @escaping (EndReceivingSoundResponse) -> ()) {
        digestTimer?.invalidate()
        
        audioInput?.stopRecording() { failure in
            guard failure == nil else {
                completion(.init(failure: failure, measurement: nil))
                return
            }
            
            guard let startDate = self.startDate, !self.magnitudes.isEmpty else {
                completion(.init(failure: nil, measurement: nil))
                return
            }
            let endDate = Date()
            completion(.init(failure: nil, measurement: Measurement(startDate: startDate, endDate: endDate, magnitudes: self.magnitudes)))
        }
    }
    
}
