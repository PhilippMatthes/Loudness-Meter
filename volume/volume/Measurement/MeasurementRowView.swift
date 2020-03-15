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
    var color: Color = Colors.blue
    @State var isExpanded = false
    var shouldExpandOnAppear = false
    var deleteAction: () -> Void
    
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
                if !isExpanded {
                    MeasurementGraph(measurement: measurement, fill: self.color)
                        .frame(width: 64, height: 32)
                }
                
                VStack(alignment: .leading) {
                    Text("\(Int(measurement.averageMagnitude)) dB")
                        .font(.headline)
                    Text("\(measurement.endDate, formatter: dateFormatter)")
                }
                
                Spacer()

                Button(action: {
                    withAnimation {
                        self.isExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle")
                        .imageScale(.large)
                        .accentColor(Color.black)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .scaleEffect(isExpanded ? 1.5 : 1)
                }
            }
            .padding(12)

            if isExpanded {
                VStack(alignment: .center) {
                    
                    HStack {
                        HStack {
                            Text("\(measurement.magnitudes.count)")
                            Text("Entries")
                            
                        }
                        Spacer()
                        Text("Max: \(Int(measurement.magnitudes.max() ?? 0)) dB")
                        Spacer()
                        HStack {
                            Text("\(max(2, measurement.magnitudes.count / Measurement.maxBuckets))")
                            Text("Entries / Bar")
                        }
                    }
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    
                    MeasurementGraph(
                        measurement: measurement,
                        fill: self.color
                    )
                    .frame(height: 218)
                    .padding(.horizontal, 12)
                
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(measurement.startDate, formatter: timeFormatter)")
                            Spacer()
                            Text("Min: \(Int(measurement.magnitudes.min() ?? 0)) dB")
                            .font(.footnote)
                            Spacer()
                            Text("\(measurement.endDate, formatter: timeFormatter)")
                        }
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(Int(measurement.averageMagnitude)) dB")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Average magnitude")
                                    .font(.footnote)
                            }
                            Spacer()
                            Button(action: self.deleteAction) {
                                Image(systemName: "trash")
                                Text("Delete")
                            }
                            .padding(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                        }
                        .padding(16)
                        .background(self.color)
                        .foregroundColor(Color.white)
                    }
                }
                .transition(bigGraphTransition)
            }
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(8)
        .padding(.horizontal, isExpanded ? 8 : 16)
        .shadow(color: isExpanded ? Color.black.opacity(0.2) : Color.black.opacity(0.1), radius: 22, x: 0, y: 32)
        .onAppear {
            if self.shouldExpandOnAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isExpanded = true
                }
            }
        }
    }
}


#if DEBUG

struct MeasurementRowView_Previews: PreviewProvider {
    static var previews: some View {
        var measurements = (0...2).map {
            measurementIndex in
            Measurement(
                startDate: Date(),
                endDate: Date().addingTimeInterval(10000),
                magnitudes: (0...Int.random(in: 10...200)).map {_ in Double.random(in: 0...140)}
            )!
        }
        
        return ScrollView {
            ForEach(measurements.indices, id: \.self) {
                measurementIndex -> MeasurementRowView in
                let measurement = measurements[measurementIndex]
                return MeasurementRowView(
                    measurement: measurement,
                    shouldExpandOnAppear: measurementIndex == 0,
                    deleteAction: {
                        measurements = measurements.filter {$0 == measurement}
                    }
                )
            }
        }
    }
}

#endif
