//
//  Measurement.swift
//  Loudness Meter
//
//  Created by Philipp Matthes on 21.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

class Measurement: NSObject, NSCoding  {
    var identifier: String?
    var soundLog: [Double]?
    var date: String?
    
    init(identifier: String,
         soundLog:[Double],
         date: String) {
        self.identifier = identifier
        self.soundLog = soundLog
        self.date = date
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let identifier = aDecoder.decodeObject(forKey: "identifier") as? String,
            let date = aDecoder.decodeObject(forKey: "date") as? String,
            let soundLog = aDecoder.decodeObject(forKey: "soundLog") as? [Double]
            else {
                return nil
        }
        self.init(identifier: identifier,
                  soundLog: soundLog,
                  date: date)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(soundLog, forKey: "soundLog")
        aCoder.encode(date, forKey: "date")
    }
}

