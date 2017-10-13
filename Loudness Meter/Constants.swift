//
//  Constants.swift
//  DragTimer
//
//  Created by Philipp Matthes on 27.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let cornerRadius = CGFloat(5.0)
    
    
    static let backgroundColor0 = UIColor(rgb: 0x3F5EFB, alpha: 1.0)
    static let backgroundColor1 = UIColor(rgb: 0xFC466B, alpha: 1.0)

    
    static let font = UIFont(name: "Futura", size: 22.0)
    
    static let information = [(UIImage(named: "0"), "Threshold to noise awareness"),
                              (UIImage(named: "10"), "Leaves rustling in the distance without environment noise"),
                              (UIImage(named: "20"), "Background noise in a quiet tv-studio"),
                              (UIImage(named: "30"), "Sleeping room without noise"),
                              (UIImage(named: "40"), "Quiet library"),
                              (UIImage(named: "50"), "Normal apartment noise"),
                              (UIImage(named: "60"), "1m away from a normal conversation"),
                              (UIImage(named: "70"), "1m away from a vacuum cleaner"),
                              (UIImage(named: "80"), "5m away from a crowded street"),
                              (UIImage(named: "90"), "10m away from a diesel engine"),
                              (UIImage(named: "100"), "1m away from a club loudspeaker"),
                              (UIImage(named: "110"), "1m away from a chain saw"),
                              (UIImage(named: "120"), "Discomfort threshold"),
                              (UIImage(named: "130"), "Pain threshold, ear damage after short time"),
                              (UIImage(named: "140"), "30m away from a launching fighter jet")]
    
}

extension UIColor {
    convenience init(rgb: Int, alpha: CGFloat) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF)/255,
            green: CGFloat((rgb >> 8) & 0xFF)/255,
            blue: CGFloat(rgb & 0xFF)/255,
            alpha: alpha
        )
    }
    func interpolateRGBColorTo(end: UIColor, fraction: CGFloat) -> UIColor? {
        var f = max(0, fraction)
        f = min(1, fraction)
        
        guard let c1 = self.cgColor.components, let c2 = end.cgColor.components else { return nil }
        
        let r: CGFloat = CGFloat(c1[0] + (c2[0] - c1[0]) * f)
        let g: CGFloat = CGFloat(c1[1] + (c2[1] - c1[1]) * f)
        let b: CGFloat = CGFloat(c1[2] + (c2[2] - c1[2]) * f)
        let a: CGFloat = CGFloat(c1[3] + (c2[3] - c1[3]) * f)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
