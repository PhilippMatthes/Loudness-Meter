//
//  AudioWaveView.swift
//  volume
//
//  Created by It's free real estate on 11.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI

struct AudioWaveView: View {
    var bands: [Double]

    var minDB: Double = 0
    var maxDB: Double = 80
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Path { path in
                        let frame = geometry.frame(in: .local)
                        let midY = frame.minY + (frame.maxY - frame.minY) / 2
                        path.move(to: CGPoint(x: frame.minX, y: midY))
                        path.addLine(to: CGPoint(x: frame.maxX, y: midY))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [1]))
                    .foregroundColor(Color.black)
                    
                    HStack(alignment: .center, spacing: 8) {
                        ForEach(self.bands.indices, id: \.self) { bandIndex in
                            RoundedRectangle(cornerRadius: 8, style: .circular)
                                .frame(height: max(8, CGFloat(max(self.minDB, min(self.maxDB, self.bands[bandIndex])) / self.maxDB) * geometry.size.height))
                        }
                    }
                }
            }
        }
    }
}

struct AudioWaveView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioWaveView(bands: [0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40, 0, 10, 20, 30, 10, 5, 0, 140, 5, 50, 40])
                .frame(height: 100)
                .foregroundColor(Color.white)
        }
        .padding(16)
        .background(Color.red)
        .cornerRadius(32)
    }
}
