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
    
    var body: some View {        
        return VStack {
            Spacer()
            
            if orchestrator.data.isRecording {
                Button(action: {
                    self.orchestrator.endRecording()
                }) {
                    Text("End Recording")
                }
            } else {
                Button(action: {
                    self.orchestrator.startRecording()
                }) {
                    Text("Start Recording")
                }
            }
            
            Spacer()
            
            AudioView(bands: self.orchestrator.data.bands)
                .frame(height: 100)
        }
        .edgesIgnoringSafeArea(.bottom)
        
    }
}


#if DEBUG

struct MeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        return MeasurementView().environmentObject(MeasurementOrchestrator(bands: [
            0, 10, 40, 20, 50, 60, 10, 0, 10, 20, 32
        ]))
    }
}

#endif

