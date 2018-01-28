//
//  Extensions.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/17/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation
import Alamofire


public extension String {
    /**
    Check if address is a valid XRB address.

    - Returns: Bool
    */
    public func validAddress() -> Bool {
        if self.range(of: "^xrb_[a-z0-9]{60}$", options: .regularExpression) != nil {
            // Valid Raiblocks Address
            return true
        } else {
            // Not Valid Raiblocks Address
            return false
        }
    }
}

/**
 Pulls address out of RaiBlocks url or QR Code
*/
func processAddress(url: String, completionHandler: @escaping (String) -> ()) {
    var address: String = url
    
    // strip after ?
    if let urlRange = address.range(of:"?") {
        address.removeSubrange(urlRange.lowerBound..<address.endIndex)
    }
    
    address = address.replacingOccurrences(of: "xrb:", with: "")
    
    if address.validAddress() {
        completionHandler(address)
    } else {
        completionHandler("")
        print("Address processing error")
    }
}

// MARK: Check Network
class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
