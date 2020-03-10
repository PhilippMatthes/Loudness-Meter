//
//  MeasurementRowView.swift
//  volume
//
//  Created by It's free real estate on 10.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI
import UIKit

struct MeasurementRowView: View {
    var measurement: Measurement
    @State var showDetail = false
    
    var bigGraphTransition: AnyTransition {
        let insertion = AnyTransition.move(edge: .bottom)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.8))
        let removal = AnyTransition.move(edge: .bottom)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.8))
        return .asymmetric(insertion: insertion, removal: removal)
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        return VStack(alignment: .leading) {
            HStack {
                if !showDetail {
                    MeasurementGraph(measurement: measurement, color: Color.red)
                        .frame(width: 64, height: 32)
                }
                
                VStack(alignment: .leading) {
                    Text("\(Int(measurement.magnitudes.average.dbValue)) dB")
                        .font(.headline)
                    Text("\(measurement.endDate, formatter: dateFormatter)")
                }
                
                Spacer()

                Button(action: {
                    withAnimation {
                        self.showDetail.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle")
                        .imageScale(.large)
                        .accentColor(Color.black)
                        .rotationEffect(.degrees(showDetail ? 90 : 0))
                        .scaleEffect(showDetail ? 1.5 : 1)
                }
            }
            .padding(16)

            if showDetail {
                VStack(alignment: .leading) {
                    
                    MeasurementGraph(measurement: measurement, color: Color.red)
                        .frame(height: 200)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(measurement.startDate, formatter: timeFormatter)")
                            Spacer()
                            Text("\(measurement.magnitudes.count) Data Points")
                            Spacer()
                            Text("\(measurement.endDate, formatter: timeFormatter)")
                        }
                        .font(.footnote)
                        .padding(16)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(Int(measurement.magnitudes.average.dbValue)) dB")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Average magnitude")
                                    .font(.footnote)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.red)
                        .foregroundColor(Color.white)
                    }
                }
                .transition(bigGraphTransition)
            }
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(8)
        .padding(.horizontal, showDetail ? 8 : 16)
        .shadow(color: showDetail ? Color.red.opacity(0.2) : Color.red.opacity(0.05), radius: 12, x: 0, y: 12)
        .shadow(color: showDetail ? Color.black.opacity(0.2) : Color.black.opacity(0.1), radius: 22, x: 0, y: 32)
    }
}


#if DEBUG

struct MeasurementRowView_Previews: PreviewProvider {
    static var previews: some View {
        let measurements = (0...2).map {
            measurementIndex in
            Measurement(
                startDate: Date(),
                endDate: Date().addingTimeInterval(10000),
                magnitudes: (0...Int.random(in: 10...200)).map {_ in Double.random(in: -50...50)}
            )!
        }
        
        return ScrollView {
            MeasurementRowView(
                measurement: measurements[0],
                showDetail: true
            )
            ForEach(measurements) {
                measurement in
                MeasurementRowView(
                    measurement: measurement,
                    showDetail: false
                )
            }
        }
    }
}

#endif
