/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The elevation, heart rate, and pace of a hike plotted on a graph.
*/

import SwiftUI

func rangeOfRanges<C: Collection>(_ ranges: C) -> Range<Double>
    where C.Element == Range<Double> {
    guard !ranges.isEmpty else { return 0..<0 }
    let low = ranges.lazy.map { $0.lowerBound }.min() ?? 0
    let high = ranges.lazy.map { $0.upperBound }.max() ?? 0
    return low..<high
}

func magnitude(of range: Range<Double>) -> Double {
    return range.upperBound - range.lowerBound
}


extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.6)
            .speed(2)
            .delay(0.03 * Double(index))
    }
}


struct MeasurementGraph<F: ShapeStyle>: View {
    var measurement: Measurement
    var fill: F
    
    var body: some View {
        let data = measurement.buckets
        let overallRange = rangeOfRanges(data.lazy.map { $0.range })
        let maxMagnitude = data.map { magnitude(of: $0.range) }.max()!
        let heightRatio = (1 - CGFloat(maxMagnitude / magnitude(of: overallRange))) / 2

        return GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(data.indices, id: \.self) { index in
                    GraphCapsule(
                        index: index,
                        height: geometry.size.height,
                        range: data[index].range,
                        overallRange: overallRange,
                        fill: self.fill
                    )
                    .transition(.slide)
                    .animation(.ripple(index: index))
                }
                .offset(x: 0, y: geometry.size.height * heightRatio)
            }
            .frame(height: geometry.size.height)
        }
    }
}

#if DEBUG

let measurement1 = Measurement(startDate: Date().addingTimeInterval(-10000), endDate: Date(), magnitudes: [5, 2, 10, 22])!
let measurement2 = Measurement(startDate: Date().addingTimeInterval(-10000), endDate: Date(), magnitudes: (0...300).map {_ in Double.random(in: 0...120)})!

struct MeasurementGraph_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MeasurementGraph(measurement: measurement1, fill: Color.blue)
                .frame(height: 300)
                .padding(1)
                .background(Color.red)
        }
    }
}

#endif
