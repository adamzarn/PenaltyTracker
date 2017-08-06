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
    
    static let shared = GlobalFunctions()
    private override init() {
        super.init()
    }
    
}
