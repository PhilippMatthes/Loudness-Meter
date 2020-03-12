//
//  ChartView.swift
//  volume
//
//  Created by It's free real estate on 12.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI


struct ChartView: View {
    @State var isMicrophoneEnabled = false
    @State var nodgeWidth: CGFloat = 128
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                VStack {
                    CardView(
                        nodgeWidth: $nodgeWidth,
                        fill: LinearGradient(
                            gradient: Gradients.clouds,
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 0)
                .padding(.top, 32)
                
                VStack {
                    HStack {
                        if isMicrophoneEnabled {
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.2), Color.red.opacity(0.3)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 56, height: 56)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "mic.fill")
                                        .imageScale(.large)
                                        .foregroundColor(Color.black)
                                }
                            }
                            .transition(.offset(x: 36))
                        }
                        
                        Button(action: {
                            withAnimation {
                                self.isMicrophoneEnabled.toggle()
                                self.nodgeWidth = self.isMicrophoneEnabled ? 312 : 128
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.2), Color.red.opacity(0.3)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 56, height: 56)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 48, height: 48)
                                Image(systemName: "mic.fill")
                                    .imageScale(.large)
                                    .foregroundColor(Color.black)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .frame(height: 512)
        }
        .background(LinearGradient(
            gradient: Gradients.playingWithReds,
            startPoint: .bottom,
            endPoint: .top
        ))
        .edgesIgnoringSafeArea(.vertical)
    }
}




struct CardView<F: ShapeStyle>: View {
    var topLeftCornerRadius: CGFloat = 32
    var topRightCornerRadius: CGFloat = 32
    var nodgeHeight: CGFloat = 32
    @Binding var nodgeWidth: CGFloat
    var fill: F
    
    var body: some View {
        GeometryReader { geometry in
            SimilarShape(path: Path { path in
                let frame = geometry.frame(in: .local)
                let centerX = frame.minX + (frame.maxX - frame.minX) / 2
                let nodgeBottomY = frame.minY + self.nodgeHeight
                
                // Bottom left
                path.move(to: CGPoint(x: frame.minX, y: frame.maxY))
                
                // Top left
                path.addLine(to: CGPoint(x: frame.minX, y: frame.minY + self.topLeftCornerRadius))
                path.addQuadCurve(
                    to: CGPoint(x: frame.minX + self.topLeftCornerRadius, y: frame.minY),
                    control: CGPoint(x: frame.minX, y: frame.minY)
                )
                
                // Nodge
                path.addLine(to: CGPoint(x: centerX - (self.nodgeWidth / 2), y: frame.minY))
                path.addCurve(
                    to: CGPoint(x: centerX, y: nodgeBottomY),
                    control1: CGPoint(x: centerX - (self.nodgeWidth / 4), y: frame.minY),
                    control2: CGPoint(x: centerX - (self.nodgeWidth / 4), y: nodgeBottomY)
                )
                path.addCurve(
                    to: CGPoint(x: centerX + (self.nodgeWidth / 2), y: frame.minY),
                    control1: CGPoint(x: centerX + (self.nodgeWidth / 4), y: nodgeBottomY),
                    control2: CGPoint(x: centerX + (self.nodgeWidth / 4), y: frame.minY)
                )
                
                
                // Top right
                path.addLine(to: CGPoint(x: frame.maxX - self.topRightCornerRadius, y: frame.minY))
                path.addQuadCurve(
                    to: CGPoint(x: frame.maxX, y: frame.minY + self.topRightCornerRadius),
                    control: CGPoint(x: frame.maxX, y: frame.minY)
                )
                
                // Bottom right
                path.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
                
                // Bottom edge
                path.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
            })
            .fill(Color.white)
        }
    }
}


struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
