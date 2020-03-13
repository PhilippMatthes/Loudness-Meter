//
//  MicrophoneButton.swift
//  volume
//
//  Created by It's free real estate on 13.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI

struct MicrophoneButton: View {
    @Binding var isActive: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradients.kimoby,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 56, height: 56)
                        .opacity(0.2)
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradients.kimoby,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 48, height: 48)
                    if isActive {
                        Image(systemName: "mic.slash.fill")
                            .imageScale(.large)
                            .foregroundColor(Color.white)
                    } else {
                        Image(systemName: "mic.fill")
                            .imageScale(.large)
                            .foregroundColor(Color.white)
                    }
                }
            }
        }
    }
}

