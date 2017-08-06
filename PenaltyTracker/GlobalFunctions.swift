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
    
    static let shared = GlobalFunctions()
    private override init() {
        super.init()
    }
    
}
