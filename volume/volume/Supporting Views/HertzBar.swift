//
//  HertzBar.swift
//  volume
//
//  Created by It's free real estate on 11.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI

struct HertzBar: View {
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Path { path in
                    let frame = geometry.frame(in: .local)
                    path.move(to: CGPoint(x: frame.minX, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: frame.minX + frame.height, y: frame.height),
                        control: CGPoint(x: frame.minX, y: frame.height)
                    )
                    path.addLine(to: CGPoint(x: frame.maxX - frame.height, y: frame.height))
                    path.addQuadCurve(
                        to: CGPoint(x: frame.maxX, y: 0),
                        control: CGPoint(x: frame.maxX, y: frame.height)
                    )
                }
                .stroke(style: StrokeStyle(lineWidth: 1))
            }
            HStack {
                Text("20 Hz")
                    .font(.footnote)
                Spacer()
                Text("20 kHz")
                    .font(.footnote)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
        }
        .frame(height: 12)
        .padding(.top, 4)
    }
}

struct HertzBar_Previews: PreviewProvider {
    static var previews: some View {
        HertzBar()
    }
}
