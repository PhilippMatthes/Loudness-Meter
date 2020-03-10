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
            if orchestrator.isRecording {
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
            if orchestrator.measurement != nil {
                MeasurementGraph(
                    measurement: orchestrator.measurement!,
                    color: Color.gray.opacity(0.5)
                )
                    .frame(height: 100)
                    .padding(12)
            }
        }
    }
}


#if DEBUG

struct MeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        return MeasurementView().environmentObject(MeasurementOrchestrator())
    }
}

#endif

