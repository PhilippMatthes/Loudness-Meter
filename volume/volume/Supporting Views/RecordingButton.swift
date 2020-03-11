//
//  RecordingButton.swift
//  volume
//
//  Created by It's free real estate on 11.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI

struct RecordingButton: View {
    var isRecording: Bool
    var action: () -> Void
    
    var body: some View {
        VStack {
            Group {
                if !self.isRecording {
                    Button(action: action) {
                        Image(systemName: "square.and.arrow.down.fill")
                            .imageScale(.large)
                        Text("Start Recording")
                    }
                } else {
                    Button(action: action) {
                        Image(systemName: "checkmark.square.fill")
                            .imageScale(.large)
                        Text("Finish Recording")
                    }
                }
            }
            .transition(.opacity)
            .padding(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
            .padding(12)
            .foregroundColor(Color.white)
        }
    }
}


