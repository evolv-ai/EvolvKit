//
//  Extensions.swift
//  Alamofire
//
//  Created by phyllis.wong on 7/9/19.
//

import UIKit

extension UIColor {
    
    public convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        guard let hex = Int(hexString, radix: 16) else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }
        
        self.init(red: CGFloat((hex >> 16) & 0xff),
                  green: CGFloat((hex >> 8) & 0xff),
                  blue: CGFloat(hex & 0xff),
                  alpha: alpha)
    }
    
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        return String(format: "#%06x", rgb)
    }
    
}
