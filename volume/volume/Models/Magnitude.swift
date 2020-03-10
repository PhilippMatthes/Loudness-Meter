//
//  Magnitude.swift
//  volume
//
//  Created by It's free real estate on 10.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation

typealias Magnitude = Double

extension Magnitude {
    var dbValue: Double {
        var value: Double = 0
        for (i, coefficient) in [137.92, 7.54, 0.14, 8.42e-4].enumerated() {
            value += pow(self, Double(i)) * coefficient
        }
        return max(0, value)
    }
}
