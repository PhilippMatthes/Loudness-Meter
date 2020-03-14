//
//  AudioBar.swift
//  volume
//
//  Created by It's free real estate on 13.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI

struct AudioBar<BackgroundFill: ShapeStyle, Fill: ShapeStyle>: View {
    var maxDB: Int = 140
    var minDB: Int = 0
    var markSize: Int = 5
    var bigMarks: [Int] = [0, 20, 40, 60, 80, 100, 120, 140]
    var barWidth: CGFloat = 58
    var barBottomInset: CGFloat = 58
    
    var currentDB: CGFloat
    var barFill: Fill
    var barBackgroundFill: BackgroundFill
    
    func percentage(of db: CGFloat) -> CGFloat {
        (min(max(0, db), CGFloat(self.maxDB)) / (CGFloat(self.maxDB - self.minDB)))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Capsule()
                    .fill(self.barBackgroundFill)
                    .frame(width: self.barWidth, height: geometry.size.height)
                VStack {
                    Spacer()
                    Capsule()
                    .fill(self.barFill)
                        .frame(width: self.barWidth, height: self.barBottomInset + (self.barWidth / 2) + self.percentage(of: self.currentDB) * (geometry.frame(in: .local).height - self.barWidth - self.barBottomInset))
                }
                
                VStack(alignment: .trailing) {
                    Text("\(self.maxDB) dB")
                    Spacer()
                    Text("\(self.minDB) dB")
                }
                .font(.footnote)
                .offset(x: -self.barWidth - 4, y: -self.barBottomInset / 2)
                .frame(height: geometry.size.height - self.barBottomInset - (self.barWidth / 2))
                
                ForEach(Array(stride(
                    from: self.minDB,
                    through: self.maxDB,
                    by: self.markSize
                )), id: \.self) { db in
                    Path { path in
                        let frame = geometry.frame(in: .local)
                        let padding = self.barWidth / 2
                        let usableHeight = frame.height - self.barWidth - self.barBottomInset
                        let offsetHeight = frame.maxY - (padding + (usableHeight * self.percentage(of: CGFloat(db)))) - self.barBottomInset
                        let centerX = frame.minX + (frame.maxX - frame.minX) / 2
                        let width = self.bigMarks.contains(db) ? self.barWidth / 4 : self.barWidth / 8
                        let barLeftX = centerX - (self.barWidth / 2)
                        path.move(to: CGPoint(x: barLeftX, y: offsetHeight))
                        path.addLine(to: CGPoint(x: barLeftX + width, y: offsetHeight))
                    }
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
            }
        }
    }
}

struct AudioBar_Previews: PreviewProvider {
    static var previews: some View {
        AudioBar(currentDB: 50, barFill: LinearGradient(gradient: Gradients.kimoby, startPoint: .top, endPoint: .bottom), barBackgroundFill: LinearGradient(gradient: Gradients.clouds, startPoint: .top, endPoint: .bottom))
    }
}
