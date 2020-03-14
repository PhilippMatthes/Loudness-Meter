/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A single line in the graph.
*/

import SwiftUI

struct GraphCapsule<F: ShapeStyle>: View {
    var index: Int
    var height: CGFloat
    var range: Range<Double>
    var overallRange: Range<Double>
    var fill: F
    
    var heightRatio: CGFloat {
        max(CGFloat(magnitude(of: range) / magnitude(of: overallRange)), 0.15)
    }
    
    var offsetRatio: CGFloat {
        CGFloat((range.lowerBound - overallRange.lowerBound) / magnitude(of: overallRange))
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
        .fill(fill)
        .frame(height: height * heightRatio)
        .offset(x: 0, y: height * -offsetRatio)
    }
}

struct GraphCapsule_Previews: PreviewProvider {
    static var previews: some View {
        let measurement2 = Measurement(startDate: Date().addingTimeInterval(-10000), endDate: Date(), magnitudes: [5, 2, 10, 22])!
        
        return MeasurementGraph(measurement: measurement2, fill: Color.blue)
           .frame(height: 300)
           .background(Color.red)
    }
}
