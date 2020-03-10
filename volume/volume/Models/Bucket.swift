//
//  Bucket.swift
//  volume
//
//  Created by It's free real estate on 10.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation

struct Bucket: Codable, Hashable {
    var range: Range<Magnitude>
    var median: Magnitude
    
    init?(chunk: [Magnitude]) {
        guard !chunk.isEmpty else {return nil}
        
        let sortedChunk = chunk.sorted()
        
        if sortedChunk.count % 2 == 0 {
            median = (sortedChunk[(sortedChunk.count / 2)] + sortedChunk[(sortedChunk.count / 2) - 1]) / 2
        } else {
            median = sortedChunk[(sortedChunk.count - 1) / 2]
        }
        
        range = sortedChunk.first!..<sortedChunk.last!
    }
}
