//
//  MagnitudeExplanationView.swift
//  volume
//
//  Created by It's free real estate on 14.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI

struct MagnitudeExplanationView: View {
    var currentMagnitude: Magnitude
    var digestedMagnitude: Magnitude
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(Int(digestedMagnitude)) dB")
                .font(.title)
            
            Group {
                if digestedMagnitude < 20 {
                    Text("Very quiet ambient noise")
                        .padding(.top, 6)
                    Text("A volume lower than 20 dB can be found in particularly quiet places without wind.")
                        .padding(.top, 6)
                    Spacer()
                    Image("undraw_not_found").resizable().scaledToFit()
                } else if digestedMagnitude < 40 {
                    Text("Quiet ambient noise")
                        .padding(.top, 6)
                    Text("A noise level between 20 dB and 40 dB can usually be found in quiet apartments with minor background noise, e.g. a running fan.")
                        .padding(.top, 6)
                    Spacer()
                    Image("undraw_yoga").resizable().scaledToFit()
                    
                } else if digestedMagnitude < 60 {
                    Text("Normal ambient noise")
                        .padding(.top, 6)
                    Text("If the 40 dB threshold is exceeded, it is usually more difficult to concentrate. 40-60 dB corresponds to e.g. a normal conversation or a television.")
                        .padding(.top, 6)
                    Spacer()
                    Image("undraw_small_town").resizable().scaledToFit()
                    
                } else if digestedMagnitude < 80 {
                    Text("Moderate ambient noise")
                        .padding(.top, 6)
                    Text("If you are permanently exposed to a volume of over 60 dB, the risk of cardiovascular diseases increases. A volume between 60 dB and 80 dB roughly corresponds to a vacuum cleaner or a car.")
                        .padding(.top, 6)
                    Spacer()
                    Image("undraw_town").resizable().scaledToFit()
                    
                } else if digestedMagnitude < 100 {
                    Text("High ambient noise")
                        .padding(.top, 6)
                    Text("From a volume of approx. 80 dB, noise is perceived as unpleasant for people. With prolonged exposure to noise, hearing damage can occur. 80 dB to 100 dB correspond to loud ear phones.")
                        .padding(.top, 6)
                    Spacer()
                    Image("undraw_happy_music").resizable().scaledToFit()
                    
                } else if digestedMagnitude < 120 {
                    Text("Very high ambient noise")
                        .padding(.top, 6)
                    Text("Continuous noise exposure above 100 dB should be avoided to prevent hearing damage. For example, noise sources such as chainsaws can be found in the range between 100 dB and 120 dB.")
                        .padding(.top, 6)
                    Spacer()
                    Image("undraw_aircraft").resizable().scaledToFit()
                    
                } else {
                    Text("Dangerous ambient noise")
                        .padding(.top, 6)
                    Text("Noises above 120 dB can cause hearing damage after a short period of time. Such noise levels should therefore be avoided. Noises above 140 dB are as loud as a rocket launch or a gun bang.")
                        .padding(.top, 6)
                    Spacer()
                    Image("undraw_maker_launch").resizable().scaledToFit()
                }
            }
            .font(.system(size: 12))
        }
    }
}

struct MagnitudeExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        MagnitudeExplanationView(currentMagnitude: 0, digestedMagnitude: 0)
    }
}
