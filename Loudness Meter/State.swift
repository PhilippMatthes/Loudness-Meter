//
//  State.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

class State {
    
    static let shared = State()
    
    let defaults = UserDefaults.standard
    var coefficients: [CGFloat] = Constants.coefficients {
        willSet(newCoefficients) {
            State.shared.store(newCoefficients, withIdentifier: "coefficients")
        }
    }
    
    private init() {
        
    }
    
    func load() {
        if let coefficients = UserDefaults.loadObject(ofType: coefficients, withIdentifier: "coefficients") {
            State.shared.coefficients = coefficients
        }
    }
    
    func store(_ string: String, withIdentifier identifier: String) {
        UserDefaults.save(object: string, withIdentifier: identifier)
    }
    
    func store(_ coefficients: [CGFloat], withIdentifier identifier: String) {
        UserDefaults.save(object: coefficients, withIdentifier: identifier)
    }
    
}
