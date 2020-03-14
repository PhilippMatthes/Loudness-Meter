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
        var isReceivingAudio: Bool
        var bands: [Magnitude]
        var currentMagnitude: Magnitude
    }
    
    @Published public var data: MeasurementOrchestrator.Data
    public let objectWillChange = PassthroughSubject<MeasurementOrchestrator.Data, Never>()
    
    private var audioInput: TempiAudioInput?
    private let sampleRate: Float = 44100
    private let refreshRate: Double = 1
    private let numberOfBands = 24
    
    private var startDate: Date?
    private var magnitudes = [Magnitude]()
    
    
    init(isReceivingAudio: Bool = false, bands: [Double] = [], currentMagnitude: Double = 0) {
        data = .init(
            isReceivingAudio: isReceivingAudio,
            bands: bands,
            currentMagnitude: currentMagnitude
        )
        super.init()
    }
    
    public func startReceivingSound() {
        magnitudes = []
        startDate = Date()
        
        data.isReceivingAudio = true
        objectWillChange.send(data)
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.audioInputCallback(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }

        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: sampleRate, numberOfChannels: 1, refreshRate: refreshRate)
        audioInput!.startRecording()
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
        
        guard data.isReceivingAudio else {return}
        data.bands = (0..<fft.numberOfBands).map { bandIndex in
            let magnitude = fft.magnitudeAtBand(bandIndex)
            // Incoming magnitudes are linear, making it impossible to see very low or very high values. Decibels to the rescue!
            let magnitudeDB = Double(TempiFFT.toDB(magnitude))
            // Normalize the incoming magnitude so that -Inf = 0
            return max(0, magnitudeDB + abs(minDB))
        }
        
        data.currentMagnitude = data.bands.reduce(0, +) / Double(data.bands.count)
        magnitudes.append(data.currentMagnitude)
        
        DispatchQueue.main.async {
            self.objectWillChange.send(self.data)
        }
    }
    
    @discardableResult public func endReceivingSound() -> Measurement? {
        data.isReceivingAudio = false
        objectWillChange.send(data)
        audioInput?.stopRecording()
        
        guard let startDate = startDate, !magnitudes.isEmpty else {return nil}
        let endDate = Date()
        return Measurement(startDate: startDate, endDate: endDate, magnitudes: magnitudes)
    }
    
}
