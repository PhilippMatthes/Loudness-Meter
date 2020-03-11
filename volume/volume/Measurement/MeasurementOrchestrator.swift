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
        var isRecording: Bool = false
        var bands: [Double] = []
    }
    
    private var audioInput: TempiAudioInput?
    private let sampleRate: Float = 44100
    private let refreshRate = 0.01
    private let numberOfBands = 11
    
    public let objectWillChange = PassthroughSubject<MeasurementOrchestrator.Data, Never>()
    
    @Published public var data: MeasurementOrchestrator.Data {
        willSet{objectWillChange.send(data)}
    }
    
    init(isRecording: Bool = false, bands: [Double] = []) {
        self.data = .init(isRecording: isRecording, bands: bands)
        super.init()
    }
    
    public func startRecording() {
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.audioInputCallback(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }

        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: sampleRate, numberOfChannels: 1, refreshRate: refreshRate)
        audioInput!.startRecording()
        self.data.isRecording = true
    }
    
    private func audioInputCallback(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        // NB: The default buffer size on iOS is 512. This will not give a terribly high resolution.
        // In practice you'll want to bucket up the buffers into a larger array of at least size 2048.
        let fft = TempiFFT(withSize: numberOfFrames, sampleRate: sampleRate)
        fft.windowType = TempiFFTWindowType.hanning
        fft.fftForward(samples)
        fft.calculateLinearBands(minFrequency: 0, maxFrequency: fft.nyquistFrequency, numberOfBands: numberOfBands)

        let minDB: Double = -48
        
        DispatchQueue.main.async {
            self.data.bands = (0..<fft.numberOfBands).map { bandIndex in
                let magnitude = fft.magnitudeAtBand(bandIndex)
                // Incoming magnitudes are linear, making it impossible to see very low or very high values. Decibels to the rescue!
                let magnitudeDB = Double(TempiFFT.toDB(magnitude))
                // Normalize the incoming magnitude so that -Inf = 0
                return max(0, magnitudeDB + abs(minDB))
            }
        }
    }
    
    public func endRecording() {
        audioInput?.stopRecording()
        self.data.isRecording = false
    }
    
}
