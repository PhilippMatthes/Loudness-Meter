//
//  ContentView.swift
//  volume
//
//  Created by It's free real estate on 10.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI
import Combine


struct MeasurementView: View {
    @EnvironmentObject public var orchestrator: MeasurementOrchestrator
    
    @State var bands: [Double] = []
    @State var isReceivingAudio: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                if self.isReceivingAudio {
                    RecordingButton(isRecording: false, action: {})
                }
                
                VStack {
                    MicrophoneAccessButton(isAccessAllowed: self.isReceivingAudio, action: {
                        self.isReceivingAudio ? self.orchestrator.endReceivingSound() : self.orchestrator.startReceivingSound()
                    })
                    .padding(.bottom, self.isReceivingAudio ? 0 : 32)
                    
                    if self.isReceivingAudio {
                        VStack {
                            AudioWaveView(bands: self.bands)
                                .foregroundColor(Color.white)
                                .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
                            HertzBar()
                                .padding(.top, 8)
                                .foregroundColor(Color.white)
                                .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                        .frame(height: 200 )
                    } else {
                        HStack {
                            Spacer()
                        }
                    }
                }
                .background(Color.black)
                .cornerRadius(32, corners: [.topLeft, .topRight])
            }
            .background(Color.red)
            .cornerRadius(32, corners: [.topLeft, .topRight])
        }
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
        }
    }
}


#if DEBUG

struct MeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MeasurementView(
                bands: [
                    0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40, 0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40
                ],
                isReceivingAudio: true
            )
            .environmentObject(MeasurementOrchestrator())
            // .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            MeasurementView(
                bands: [
                    0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40, 0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40
                ],
                isReceivingAudio: false
            )
            .environmentObject(MeasurementOrchestrator())
            // .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }
}

#endif

