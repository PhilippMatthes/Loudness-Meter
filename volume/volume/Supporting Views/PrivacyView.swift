//
//  PrivacyView.swift
//  volume
//
//  Created by It's free real estate on 13.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI
import UIKit

struct PrivacyView: View {
    
    var color: Color = Color.red
    
    var body: some View {
        return VStack(alignment: .center) {
            HStack {
                
                VStack(alignment: .leading) {
                    Text("All audio data remains on this device")
                }
                
                Spacer()

                Image(systemName: "info.circle")
                    .imageScale(.large)
                    .accentColor(Color.black)
            }
            .padding(16)
            .foregroundColor(Color.white)
            .background(color)
            
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Privacy Protection")
                        .font(.headline)
                    Text("All audio data remains on this device and is not transmitted to third parties.")
                        .font(.subheadline)
                }
                
                Image("undraw_privacy_protection")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 88)
                    .padding(16)
            }
            .padding(12)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .shadow(color: self.color.opacity(0.05), radius: 12, x: 0, y: 12)
        .shadow(color: Color.black.opacity(0.1), radius: 22, x: 0, y: 32)
    }
}


#if DEBUG

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}

#endif
