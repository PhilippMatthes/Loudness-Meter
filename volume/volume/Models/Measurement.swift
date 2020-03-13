//
//  Measurement.swift
//  volume
//
//  Created by It's free real estate on 10.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import SwiftUI


internal extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

internal extension Collection where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { reduce(0, +) }
}

internal extension Collection where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    var average: Double { isEmpty ? 0 : Double(total) / Double(count) }
}

internal extension Collection where Element: BinaryFloatingPoint {
    /// Returns the average of all elements in the array
    var average: Element { isEmpty ? 0 : total / Element(count) }
}


struct Measurement: Codable, Hashable, Identifiable {
    var startDate: Date
    var endDate: Date
    var magnitudes: [Magnitude]
    
    var id: String
    var buckets: [Bucket]
    
    static let maxBuckets = 20
    
    static var savedMeasurements: [Measurement] {
        get {
            guard
                let data = UserDefaults.standard.object(forKey: "savedMeasurements") as? Data,
                let measurements = try? JSONDecoder().decode([Measurement].self, from: data)
                else {return [Measurement]()}
            return measurements
        }
        set {
            let data = try! JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: "savedMeasurements")
        }
    }
    
    init?(startDate: Date, endDate: Date, magnitudes: [Double]) {
        guard !magnitudes.isEmpty else {return nil}
        self.startDate = startDate
        self.endDate = endDate
        self.magnitudes = magnitudes
        
        self.id = "\(startDate) - \(endDate)"
        let magnitudesPerBucket = max(2, magnitudes.count / Measurement.maxBuckets)
        self.buckets = magnitudes.chunked(into: magnitudesPerBucket).compactMap {
            Bucket(chunk: $0)
        }
    }
}
