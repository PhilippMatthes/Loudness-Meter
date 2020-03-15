//
//  MeasurementView.swift
//  volume
//
//  Created by It's free real estate on 12.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI
import SwiftRater


struct MeasurementView: View {
    @EnvironmentObject var orchestrator: MeasurementOrchestrator
    
    var nodgeOffset: CGFloat {
        isReceivingAudio ? -(UIScreen.main.bounds.width / 2) + 90 : 0
    }
    
    var explanationViewLeftPadding: CGFloat {
        (UIScreen.main.bounds.width / 2) + nodgeOffset + 32
    }
    
    @State var measurements: [Measurement] = Measurement.savedMeasurements
    @State var bands: [Double] = []
    @State var currentMagnitude: Magnitude = 0
    @State var digestedMagnitude: Magnitude = 0
    @State var isReceivingAudio = false
    @State var nodgeWidth: CGFloat = 128
    @State var nodgeHeight: CGFloat = 32
    @State var recordedMeasurement: Measurement?
    
    @State var failure: TempiAudioInput.Failure? = nil
    @State var showsAlert = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                if self.isReceivingAudio {
                    Spacer()
                    ZStack {
                        AudioBar(currentDB: CGFloat(self.currentMagnitude), barFill: LinearGradient(gradient: Gradients.kimoby, startPoint: .top, endPoint: .bottom), barBackgroundFill: LinearGradient(gradient: Gradients.clouds, startPoint: .top, endPoint: .bottom))
                            .padding(.bottom, 200)
                            .offset(x: nodgeOffset)
                            .transition(.move(edge: .bottom))
                        
                        VStack {
                            MagnitudeExplanationView(currentMagnitude: self.currentMagnitude, digestedMagnitude: self.digestedMagnitude)
                                .padding(.bottom, 238)
                                .padding(.horizontal, 8)
                                .padding(.leading, explanationViewLeftPadding)
                            Spacer()
                        }
                    }
                } else {
                    if self.measurements.isEmpty {
                        PrivacyView()
                            .padding(.top, 12)
                        Spacer()
                        VStack {
                            Text("Getting Started")
                                .font(.headline)
                                .padding(.bottom, 12)
                            Text("Tap the microphone button to start your measurement. Finish your measurement by tapping the microphone button again.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 128)
                    } else {
                        ScrollView(showsIndicators: false) {
                            Text("Measurements")
                                .font(.largeTitle)
                                .padding(.horizontal, 28)
                            ForEach(measurements, id: \.self) { measurement in
                                MeasurementRowView(
                                    measurement: measurement,
                                    shouldExpandOnAppear: measurement == self.recordedMeasurement,
                                    deleteAction: {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            self.measurements = self.measurements.filter {$0 != measurement}
                                            Measurement.savedMeasurements = self.measurements
                                        }
                                    }
                                )
                            }
                            Spacer(minLength: self.isReceivingAudio ? 264 : 96)
                        }
                    }
                }
            }

            
            VStack {
                Spacer()
                
                ZStack {
                    ZStack {
                        CardView(
                            nodgeOffset: nodgeOffset,
                            nodgeHeight: $nodgeHeight,
                            nodgeWidth: $nodgeWidth,
                            fill: LinearGradient(
                                gradient: Gradients.kimoby,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        
                        VStack {
                            if self.isReceivingAudio {
                                AudioWaveView(bands: self.bands)
                                    .transition(.opacity)
                                    .padding(.top, 42)
                                    .foregroundColor(Color.white)
                                HertzBar()
                                    .padding(.top, 8)
                                    .foregroundColor(Color.white)
                                    .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                    }
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 0)
                    .padding(.top, 32)
                    
                    VStack {
                        MicrophoneButton(isActive: self.$isReceivingAudio, action: {
                            if self.isReceivingAudio {
                                self.orchestrator.endReceivingSound() {response in
                                    if let failure = response.failure {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            self.failure = failure
                                            self.showsAlert = true
                                        }
                                    } else {
                                        if let measurement = response.measurement {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                self.isReceivingAudio = false
                                                self.recordedMeasurement = measurement
                                                self.measurements = [measurement] + self.measurements
                                                Measurement.savedMeasurements = self.measurements
                                            }
                                        }
                                    }
                                }
                            } else {
                                self.orchestrator.startReceivingSound { failure in
                                    if let failure = failure {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            self.isReceivingAudio = false
                                            self.failure = failure
                                            self.showsAlert = true
                                        }
                                    } else {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            self.isReceivingAudio = true
                                        }
                                    }
                                }
                            }
                        })
                        .offset(x: nodgeOffset)
                        .alert(isPresented: self.$showsAlert) {
                            switch self.failure {
                            case .permissionsDenied:
                                return Alert(
                                    title: Text("Microphone access denied."),
                                    message: Text("The recording could not be started, because you disabled microphone access for this app. Please enable the microphone access in the device settings to start with your measurement."),
                                    dismissButton: .default(Text("OK"))
                                )
                            default:
                                return Alert(
                                    title: Text("There was a problem."),
                                    message: Text("The action you performed could not be executed. Please try again."),
                                    dismissButton: .default(Text("Dismiss"))
                                )
                            }
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: self.isReceivingAudio ? 258 : 88)
            }
        }
        .background(LinearGradient(
            gradient: Gradients.clouds,
            startPoint: .bottom,
            endPoint: .top
        ))
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            SwiftRater.check()
        }
        .onReceive(self.orchestrator.objectWillChange) { data in
            if self.bands != data.bands {
                withAnimation {
                    self.bands = data.bands
                }
            }
            if self.currentMagnitude != data.currentMagnitude {
                withAnimation {
                    self.currentMagnitude = data.currentMagnitude
                }
            }
            if self.digestedMagnitude != data.digestedMagnitude {
                withAnimation {
                    self.digestedMagnitude = data.digestedMagnitude
                }
            }
        }
    }
}


struct MeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        let measurements = (0...100).map {
            measurementIndex in
            Measurement(
                startDate: Date(),
                endDate: Date().addingTimeInterval(10000 * Double(measurementIndex)),
                magnitudes: (0...Int.random(in: 10...200)).map {_ in Double.random(in: -50...50)}
            )!
        }
        
        
        return Group {
            MeasurementView(
                measurements: measurements,
                bands: [0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40, 0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40],
                currentMagnitude: 60,
                isReceivingAudio: false
            ).environmentObject(MeasurementOrchestrator())
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .environment(\.locale, .init(identifier: "de"))
            MeasurementView(
                measurements: [],
                bands: [0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40, 0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40]
            ).environmentObject(MeasurementOrchestrator())
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }
}
