/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The elevation, heart rate, and pace of a hike plotted on a graph.
*/

import SwiftUI

func rangeOfRanges<C: Collection>(_ ranges: C) -> Range<Double>
    where C.Element == Range<Double> {
    guard !ranges.isEmpty else { return 0..<0 }
    let low = ranges.lazy.map { $0.lowerBound }.min()!
    let high = ranges.lazy.map { $0.upperBound }.max()!
    return low..<high
}

func magnitude(of range: Range<Double>) -> Double {
    return range.upperBound - range.lowerBound
}

struct MeasurementGraph: View {
    var measurement: Measurement
    var color: Color
    
    var body: some View {
        let data = measurement.buckets
        let overallRange = rangeOfRanges(data.lazy.map { $0.range })
        let maxMagnitude = data.map { magnitude(of: $0.range) }.max()!
        let heightRatio = (1 - CGFloat(maxMagnitude / magnitude(of: overallRange))) / 2

        return GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(data.indices, id: \.self) { index in
                    GraphCapsule(
                        index: index,
                        height: proxy.size.height,
                        range: data[index].range,
                        overallRange: overallRange)
                    .colorMultiply(self.color)
                }
                .offset(x: 0, y: proxy.size.height * heightRatio)
            }
        }
    }
}

#if DEBUG

let measurement1 = Measurement(startDate: Date().addingTimeInterval(-10000), endDate: Date(), magnitudes: [0, 5, 0, 20, 100, 50, 50, 60, 10, 5, 12, 30])!
let measurement2 = Measurement(startDate: Date().addingTimeInterval(-10000), endDate: Date(), magnitudes: (0...300).map {_ in Double.random(in: 0...120)})!

struct MeasurementGraph_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MeasurementGraph(measurement: measurement2, color: Color.black)
                .frame(height: 300)
                .padding(1)
        }
    }
}

#endif
