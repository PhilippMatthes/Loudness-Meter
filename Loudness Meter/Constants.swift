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
    
    static let information = [(UIImage(named: "0"), NSLocalizedString("0", comment: " ")),
                              (UIImage(named: "10"), NSLocalizedString("10", comment: " ")),
                              (UIImage(named: "20"), NSLocalizedString("20", comment: " ")),
                              (UIImage(named: "30"), NSLocalizedString("30", comment: " ")),
                              (UIImage(named: "40"), NSLocalizedString("40", comment: " ")),
                              (UIImage(named: "50"), NSLocalizedString("50", comment: " ")),
                              (UIImage(named: "60"), NSLocalizedString("60", comment: " ")),
                              (UIImage(named: "70"), NSLocalizedString("70", comment: " ")),
                              (UIImage(named: "80"), NSLocalizedString("80", comment: " ")),
                              (UIImage(named: "90"), NSLocalizedString("90", comment: " ")),
                              (UIImage(named: "100"), NSLocalizedString("100", comment: " ")),
                              (UIImage(named: "110"), NSLocalizedString("110", comment: " ")),
                              (UIImage(named: "120"), NSLocalizedString("120", comment: " ")),
                              (UIImage(named: "130"), NSLocalizedString("130", comment: " ")),
                              (UIImage(named: "140"), NSLocalizedString("140", comment: " "))]
    
    
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
