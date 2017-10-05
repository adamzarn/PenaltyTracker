//
//  GlobalFunctions.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/4/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import Foundation
import UIKit

class GlobalFunctions: NSObject {
    
    func hasConnectivity() -> Bool {
        do {
            let reachability = Reachability()
            let networkStatus: Int = reachability!.currentReachabilityStatus.hashValue
            return (networkStatus != 0)
        }
    }
    
    func bold(string: String, size: CGFloat, color: UIColor) -> NSMutableAttributedString {
        let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: size),
                     NSForegroundColorAttributeName: color]
        let attributedString = NSMutableAttributedString(string: string, attributes:attrs)
        return attributedString
    }
    
    func italic(string: String, size: CGFloat, color: UIColor) -> NSMutableAttributedString {
        let attrs = [NSFontAttributeName : UIFont.italicSystemFont(ofSize: size), NSForegroundColorAttributeName: color]
        let attributedString = NSMutableAttributedString(string: string, attributes:attrs)
        return attributedString
    }
    
    func formattedTimestamp(ts: String, includeDate: Bool, includeTime: Bool) -> String {
        let year = ts.substring(with: 2..<4)
        let month = Int(ts.substring(with: 4..<6))
        let day = Int(ts.substring(with: 6..<8))
        var hour = Int(ts.substring(with: 9..<11))
        let minute = ts.substring(with: 12..<14)
        var suffix = "AM"
        if hour! > 11 {
            suffix = "PM"
        }
        if hour! > 12 {
            hour = hour! - 12
        }
        if hour! == 0 {
            hour = 12
        }
        
        if includeDate && includeTime {
            return "\(month!)/\(day!)/\(year) \(hour!):\(minute) \(suffix)"
        } else if !includeDate && includeTime {
            return "\(hour!):\(minute) \(suffix)"
        } else if includeDate && !includeTime {
            return "\(month!)/\(day!)/\(year)"
        } else {
            return ""
        }
        
    }
    
    func convertDoubleToTime(duration: Double) -> String {
        let roundedSeconds = Int(round(duration))
        let hours = roundedSeconds / 3600
        let minutes = (roundedSeconds % 3600) / 60
        let seconds = (roundedSeconds % 3600) % 60

        let h = String(format: "%02d", hours)
        let m = String(format: "%02d", minutes)
        let s = String(format: "%02d", seconds)
        
        if hours > 0 {
            return "\(h):\(m):\(s)"
        } else {
            return "\(minutes):\(s)"
        }
    }
    
    func getCurrentDateAndTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd HH:mm:ss:SSS"
        let stringDate = formatter.string(from: date)
        return stringDate
    }
    
    func parse(pin: String) -> [String] {
        let pin1 = pin.substring(with: 0..<1)
        let pin2 = pin.substring(with: 1..<2)
        let pin3 = pin.substring(with: 2..<3)
        let pin4 = pin.substring(with: 3..<4)
        return [pin1, pin2, pin3, pin4]
    }
    
    static let shared = GlobalFunctions()
    private override init() {
        super.init()
    }
    
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
