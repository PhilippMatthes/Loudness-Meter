//
//  MicrophoneAccessButton.swift
//  volume
//
//  Created by It's free real estate on 11.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI

struct MicrophoneAccessButton: View {
    var isAccessAllowed: Bool
    var action: () -> Void
    
    var body: some View {
        VStack {
            Group {
                if !self.isAccessAllowed {
                    Button(action: action) {
                        Image(systemName: "mic.fill")
                            .imageScale(.large)
                        Text("Enable Microphone")
                    }
                } else {
                    Button(action: action) {
                        Image(systemName: "mic.slash.fill")
                            .imageScale(.large)
                        Text("Disable Microphone")
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

