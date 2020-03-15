//
//  TempiAudioInput.swift
//  TempiBeatDetection
//
//  Created by John Scalo on 1/7/16.
//  Copyright © 2016 John Scalo. See accompanying License.txt for terms.

import AVFoundation

typealias TempiAudioInputCallback = (
    _ timeStamp: Double,
    _ numberOfFrames: Int,
    _ samples: [Float]
) -> Void

/// TempiAudioInput sets up an audio input session and notifies when new buffer data is available.
class TempiAudioInput: NSObject {
    
    enum Failure {
        case permissionsDenied
        case setupFailed
        case teardownFailed
        case callbackFailed
    }
    
    private(set) var audioUnit: AudioUnit?
    let audioSession : AVAudioSession = AVAudioSession.sharedInstance()
    var sampleRate: Float
    var numberOfChannels: Int
    var refreshRate: Double

    /// When true, performs DC offset rejection on the incoming buffer before invoking the audioInputCallback.
    var shouldPerformDCOffsetRejection: Bool = false
    
    private let outputBus: UInt32 = 0
    private let inputBus: UInt32 = 1
    private var audioInputCallback: TempiAudioInputCallback!

    /// Instantiate a TempiAudioInput.
    /// - Parameter audioInputCallback: Invoked when audio data is available.
    /// - Parameter sampleRate: The sample rate to set up the audio session with.
    /// - Parameter numberOfChannels: The number of channels to set up the audio session with.
    
    init(audioInputCallback callback: @escaping TempiAudioInputCallback, sampleRate: Float = 44100.0, numberOfChannels: Int = 2, refreshRate: Double = 10) {
        self.sampleRate = sampleRate
        self.numberOfChannels = numberOfChannels
        self.refreshRate = refreshRate
        audioInputCallback = callback
    }

    /// Start recording. Prompts for access to microphone if necessary.
    func startRecording(completion: @escaping (Failure?) -> ()) {
        setupAudioSession() { failure in
            guard failure == nil else {
                completion(failure)
                return
            }
            self.setupAudioUnit() { failure in
                guard failure == nil else {
                    completion(failure)
                    return
                }
                
                do {
                    try self.audioSession.setActive(true)
                    var osErr: OSStatus = 0
                    
                    guard let audioUnit = self.audioUnit else {
                        completion(.setupFailed)
                        return
                    }
                    osErr = AudioUnitInitialize(audioUnit)
                    guard osErr == noErr else {
                        completion(.setupFailed)
                        return
                    }
                    
                    osErr = AudioOutputUnitStart(audioUnit)
                    guard osErr == noErr else {
                        completion(.setupFailed)
                        return
                    }
                } catch {
                    completion(.setupFailed)
                    return
                }
                completion(nil)
            }
        }
    }
    
    /// Stop recording.
    func stopRecording(completion: @escaping (Failure?) -> ()) {
        do {
            var osErr: OSStatus = 0
            
            if let audioUnit = self.audioUnit {
                osErr = AudioUnitUninitialize(audioUnit)
                guard osErr == noErr else {
                    completion(.teardownFailed)
                    return
                }
            }
            
            try self.audioSession.setActive(false)
        } catch {
            completion(.teardownFailed)
            return
        }
        completion(nil)
    }
    
    private let recordingCallback: AURenderCallback = { (inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData) -> OSStatus in
        
        let audioInput = unsafeBitCast(inRefCon, to: TempiAudioInput.self)
        var osErr: OSStatus = 0
        
        // We've asked CoreAudio to allocate buffers for us, so just set mData to nil and it will be populated on AudioUnitRender().
        var bufferList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels: UInt32(audioInput.numberOfChannels),
                mDataByteSize: 4,
                mData: nil))
        
        guard let audioUnit = audioInput.audioUnit else {return osErr}
        
        osErr = AudioUnitRender(
            audioUnit,
            ioActionFlags,
            inTimeStamp,
            inBusNumber,
            inNumberFrames,
            &bufferList
        )
        
        guard osErr == noErr else {return osErr}
        
        // Move samples from mData into our native [Float] format.
        var monoSamples = [Float]()
        let ptr = bufferList.mBuffers.mData?.assumingMemoryBound(to: Float.self)
        monoSamples.append(contentsOf: UnsafeBufferPointer(start: ptr, count: Int(inNumberFrames)))
        
        if audioInput.shouldPerformDCOffsetRejection {
            DCRejectionFilterProcessInPlace(&monoSamples, count: Int(inNumberFrames))
        }
        
        // Not compatible with Obj-C...
        audioInput.audioInputCallback(inTimeStamp.pointee.mSampleTime / Double(audioInput.sampleRate),
                                      Int(inNumberFrames),
                                      monoSamples)
        
        return 0
    }
    
    private func setupAudioSession(completion: @escaping (Failure?) -> ()) {
        guard audioSession.availableCategories.contains(.record) else {
            completion(.setupFailed)
            return
        }
        
        do {
            try audioSession.setCategory(.record)
            
            // "Appropriate for applications that wish to minimize the effect of system-supplied signal processing for input and/or output audio signals."
            // NB: This turns off the high-pass filter that CoreAudio normally applies.
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            
            try audioSession.setPreferredSampleRate(Double(sampleRate))
            
            // This will have an impact on CPU usage. .01 gives 512 samples per frame on iPhone. (Probably .01 * 44100 rounded up.)
            // NB: This is considered a 'hint' and more often than not is just ignored.
            try audioSession.setPreferredIOBufferDuration(refreshRate)
            
            audioSession.requestRecordPermission { (granted) -> Void in
                if granted {
                    completion(nil)
                } else {
                    completion(.permissionsDenied)
                }
            }
        } catch {
            completion(.setupFailed)
            return
        }
    }
    
    private func setupAudioUnit(completion: @escaping (Failure?) -> ()) {
        
        var componentDesc:AudioComponentDescription = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO), // Always this for iOS.
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        
        var osErr: OSStatus = 0
        
        // Get an audio component matching our description.
        guard let component = AudioComponentFindNext(nil, &componentDesc) else {
            completion(.setupFailed)
            return
        }
        
        // Create an instance of the AudioUnit
        var tempAudioUnit: AudioUnit?
        osErr = AudioComponentInstanceNew(component, &tempAudioUnit)
        self.audioUnit = tempAudioUnit
        guard let audioUnit = self.audioUnit else {
            completion(.setupFailed)
            return
        }
        
        guard osErr == noErr else {
            completion(.setupFailed)
            return
        }
        
        // Enable I/O for input.
        var one:UInt32 = 1

        osErr = AudioUnitSetProperty(audioUnit,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Input,
            inputBus,
            &one,
            UInt32(MemoryLayout<UInt32>.size))
        
        guard osErr == noErr else {
            completion(.setupFailed)
            return
        }
        
        osErr = AudioUnitSetProperty(audioUnit,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Output,
            outputBus,
            &one,
            UInt32(MemoryLayout<UInt32>.size))
        
        guard osErr == noErr else {
            completion(.setupFailed)
            return
        }
        
        // Set format to 32 bit, floating point, linear PCM
        var streamFormatDesc:AudioStreamBasicDescription = AudioStreamBasicDescription(
            mSampleRate:        Double(sampleRate),
            mFormatID:          kAudioFormatLinearPCM,
            mFormatFlags:       kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved, // floating point data - docs say this is fastest
            mBytesPerPacket:    4,
            mFramesPerPacket:   1,
            mBytesPerFrame:     4,
            mChannelsPerFrame:  UInt32(self.numberOfChannels),
            mBitsPerChannel:    4 * 8,
            mReserved: 0
        )
        
        // Set format for input and output busses
        osErr = AudioUnitSetProperty(audioUnit,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Input, outputBus,
            &streamFormatDesc,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        guard osErr == noErr else {
            completion(.setupFailed)
            return
        }
        
        osErr = AudioUnitSetProperty(audioUnit,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Output,
            inputBus,
            &streamFormatDesc,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        guard osErr == noErr else {
            completion(.setupFailed)
            return
        }
        
        // Set up our callback.
        var inputCallbackStruct = AURenderCallbackStruct(inputProc: recordingCallback, inputProcRefCon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        osErr = AudioUnitSetProperty(audioUnit,
            AudioUnitPropertyID(kAudioOutputUnitProperty_SetInputCallback),
            AudioUnitScope(kAudioUnitScope_Global),
            inputBus,
            &inputCallbackStruct,
            UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        guard osErr == noErr else {
            completion(.setupFailed)
            return
        }
        
        // Ask CoreAudio to allocate buffers for us on render. (This is true by default but just to be explicit about it...)
        osErr = AudioUnitSetProperty(audioUnit,
            AudioUnitPropertyID(kAudioUnitProperty_ShouldAllocateBuffer),
            AudioUnitScope(kAudioUnitScope_Output),
            inputBus,
            &one,
            UInt32(MemoryLayout<UInt32>.size))
        guard osErr == noErr else {
            completion(.setupFailed)
            return
        }
        
        completion(nil)
    }
}

private func DCRejectionFilterProcessInPlace(_ audioData: inout [Float], count: Int) {
    
    let defaultPoleDist: Float = 0.975
    var mX1: Float = 0
    var mY1: Float = 0
    
    for i in 0..<count {
        let xCurr: Float = audioData[i]
        audioData[i] = audioData[i] - mX1 + (defaultPoleDist * mY1)
        mX1 = xCurr
        mY1 = audioData[i]
    }
}
