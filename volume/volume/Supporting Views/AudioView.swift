//
//  AudioView.swift
//  volume
//
//  Created by It's free real estate on 10.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI
import Foundation
import UIKit


struct AudioView: View {
    var bands: [Double]
    
    var color: Color = Color.red
    
    static let gradientStart = Color(red: 240 / 255, green: 0 / 255, blue: 0 / 255)
    static let gradientEnd = Color(red: 220 / 255, green: 40 / 255, blue: 40 / 255)
    
    var animatableData: [Double] {
        get { return bands }
        set { bands = newValue }
    }
    
    var body: some View {
        let numberOfBands = self.bands.count
        
        return GeometryReader { proxy in
            Path { path in
                let frame = proxy.frame(in: .local)
                
                path.move(to: CGPoint(x: frame.minX, y: frame.minY))
                
                if numberOfBands > 0 {
                    let curvePoints = self.bands.enumerated().compactMap { (arg) -> CGPoint? in
                        let (i, band) = arg
                        let percentage = CGFloat(i) / CGFloat(numberOfBands - 1)
                        return CGPoint(
                            x: frame.minX + percentage * (frame.maxX - frame.minX),
                            y: frame.minY - CGFloat(band * 2)
                        )
                    }
                    
                    let controlPoints = path.controlPointsFromPoints(dataPoints: curvePoints)
                    for (i, point) in curvePoints.enumerated() {
                        if i == 0 {
                            path.addLine(to: point)
                        } else {
                            let segment = controlPoints[i - 1]
                            path.addCurve(to: point, control1: segment.0, control2: segment.1)
                        }
                    }
                } else {
                    path.addLine(to: CGPoint(x: frame.maxX, y: frame.minY))
                }
                
                path.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
                path.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
                path.addLine(to: CGPoint(x: frame.minX, y: frame.minY))
            }
            .fill(LinearGradient(
                gradient: .init(colors: [Self.gradientStart, Self.gradientEnd]),
                startPoint: .init(x: 0.5, y: 0),
                endPoint: .init(x: 0.5, y: 0.6)
            ))
        }
    }
}

#if DEBUG
struct AudioView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            AudioView(bands: [0, 10, 20, 30, 10, 5, 0, 100, 5, 50, 40])
                .frame(height: 300, alignment: .bottom)
        }
    }
}
#endif
