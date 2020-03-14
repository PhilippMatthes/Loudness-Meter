//
//  MeasurementView.swift
//  volume
//
//  Created by It's free real estate on 12.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI


struct MeasurementView: View {
    @EnvironmentObject var orchestrator: MeasurementOrchestrator
    
    @State var measurements: [Measurement] = Measurement.savedMeasurements
    @State var bands: [Double] = []
    @State var currentMagnitude: Magnitude = 0
    @State var isReceivingAudio = false
    @State var nodgeOffset: CGFloat = 0
    @State var nodgeWidth: CGFloat = 128
    @State var nodgeHeight: CGFloat = 32
    @State var recordedMeasurement: Measurement?
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                if self.isReceivingAudio {
                    Spacer()
                    AudioBar(currentDB: CGFloat(self.currentMagnitude), barFill: LinearGradient(gradient: Gradients.kimoby, startPoint: .top, endPoint: .bottom), barBackgroundFill: LinearGradient(gradient: Gradients.clouds, startPoint: .top, endPoint: .bottom))
                        .padding(.bottom, 200)
                    .offset(x: nodgeOffset)
                        .transition(.move(edge: .bottom))
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
                            nodgeOffset: $nodgeOffset,
                            nodgeHeight: $nodgeHeight,
                            nodgeWidth: $nodgeWidth,
                            fill: LinearGradient(
                                gradient: Gradients.kimoby,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 0)
                        .shadow(color: Colors.blue.opacity(0.2), radius: 26, x: 0, y: -12)
                        
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
                            withAnimation(.easeInOut(duration: 0.5)) {
                                self.isReceivingAudio.toggle()
                                self.nodgeWidth = self.isReceivingAudio ? 148 : 128
                                self.nodgeHeight = self.isReceivingAudio ? 38 : 32
                                self.nodgeOffset = self.isReceivingAudio ? -64 : 0
                                if self.isReceivingAudio {
                                    self.orchestrator.startReceivingSound()
                                } else {
                                    let measurement = self.orchestrator.endReceivingSound()
                                    if let measurement = measurement {
                                        self.recordedMeasurement = measurement
                                        self.measurements = [measurement] + self.measurements
                                        Measurement.savedMeasurements = self.measurements
                                    }
                                }
                            }
                        })
                        .offset(x: nodgeOffset)
                        
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
        .onReceive(self.orchestrator.objectWillChange) { data in
            if self.bands != data.bands {
                withAnimation {
                    self.bands = data.bands
                }
            }
            if self.isReceivingAudio != data.isReceivingAudio {
                withAnimation(.easeOut(duration: 1)) {
                    self.isReceivingAudio = data.isReceivingAudio
                }
            }
            if self.currentMagnitude != data.currentMagnitude {
                withAnimation {
                    self.currentMagnitude = data.currentMagnitude
                }
            }
        }
    }
}


struct MeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        let measurements = (0...2).map {
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
                isReceivingAudio: false
            ).environmentObject(MeasurementOrchestrator())
            MeasurementView(
                measurements: [],
                bands: [0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40, 0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40]
            ).environmentObject(MeasurementOrchestrator())
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }
}
